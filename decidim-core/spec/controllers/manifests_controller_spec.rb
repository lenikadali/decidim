# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ManifestsController do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization, name: { en: "Organization's name" }) }

    before do
      Decidim::Organization.destroy_all
      request.env["decidim.current_organization"] = organization
    end

    describe "GET /manifest.json" do
      render_views

      it "returns the manifest" do
        get :show, format: :json

        expect(response).to be_successful

        manifest = JSON.parse(response.body)
        expect(manifest["name"]).to eq(translated(organization.name))
        expect(manifest["lang"]).to eq(organization.default_locale)
        expect(manifest["description"]).to eq(ActionView::Base.full_sanitizer.sanitize(translated(organization.description)))
        expect(manifest["background_color"]).to eq("#FFFFFF")
        expect(manifest["theme_color"]).to eq("#e02d2d")
        expect(manifest["display"]).to eq("standalone")
        expect(manifest["start_url"]).to eq("/")
        expect(manifest["icons"]).to match(
          [
            a_hash_including("src" => a_string_starting_with("/"), "sizes" => "32x32", "type" => "image/png"),
            a_hash_including("src" => a_string_starting_with("/"), "sizes" => "180x180", "type" => "image/png"),
            a_hash_including("src" => a_string_starting_with("/"), "sizes" => "192x192", "type" => "image/png"),
            a_hash_including("src" => a_string_starting_with("/"), "sizes" => "512x512", "type" => "image/png")
          ]
        )
      end
    end
  end
end
