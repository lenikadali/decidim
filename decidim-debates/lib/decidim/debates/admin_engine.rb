# frozen_string_literal: true

module Decidim
  module Debates
    # This is the engine that runs on the public interface of `decidim-debates`.
    # It mostly handles rendering the created debate associated to a participatory
    # process.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Debates::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :debates do
          resources :debate_closes, only: [:edit, :update]

          member do
            patch :soft_delete
            patch :restore
          end

          get :manage_trash, on: :collection
        end
        root to: "debates#index"
      end

      def load_seed
        nil
      end
    end
  end
end
