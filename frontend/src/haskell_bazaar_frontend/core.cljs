(ns haskell-bazaar-frontend.core
  (:require
    [ajax.core :as ajax]
    [reagent.core :as reagent]
    [re-frame.core :as re-frame]
    [datascript.core :as d]

    [haskell-bazaar-frontend.api :as api]
    [haskell-bazaar-frontend.ds :as ds]
    [haskell-bazaar-frontend.events]  ;; Register events
    [haskell-bazaar-frontend.environment :as environment]
    [haskell-bazaar-frontend.fx :as fx]  ;; Register fx
    [haskell-bazaar-frontend.routes :as routes]
    [haskell-bazaar-frontend.stubs :as stubs]
    [haskell-bazaar-frontend.subs]    ;; Register subscriptions
    [haskell-bazaar-frontend.views.core :as views]))

;; Should only be activated in dev mode

(defonce app-setup!
  (let [env (environment/environment)]
    (when (= env :dev)
      (enable-console-print!)) ;; println is now console.log

    ;; Setting up routes
    (routes/set-config!)

    ;; Setting up stateful cofx and fx
    (let [history (routes/make-history!)
          cache (atom {}) ;; TODO: use a proper cache datastructure
          datascript-conn (d/create-conn ds/schema)
          local-storage-ttl (* 60 60)] ;; 1 hour in seconds
      (ds/init! datascript-conn)
      (fx/init! history cache local-storage-ttl))

    ;; Setting initial db
    (re-frame/dispatch-sync [:db/initialize env])
    (re-frame/dispatch-sync [:datascript/initialize env])))

;; ---------
;; app-state
;; ---------

(defn ^:export run
  []
  (let [env (environment/environment)]
    ;; Mounting React component
    (reagent/render [views/ui views/dispatchers (api/base-url env)]
                    (js/document.getElementById "app"))))

;; ---------------
;; Figwheel reload
;; ---------------

(defn on-js-reload []
  ;; optionally touch your app-state to force rerendering depending on
  ;; your application
  ;; (swap! app-state update-in [:__figwheel_counter] inc)
  (run))
