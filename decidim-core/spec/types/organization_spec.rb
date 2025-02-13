# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql class type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let(:query) do
    %(
      query {
        organization{
          name { translation(locale: "#{locale}") }
          stats{
            name
            value
          }
        }
      }
    )
  end

  describe "valid query" do
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it "has name" do
      expect(response["organization"]["name"]["translation"]).to eq(translated(current_organization.name))
    end

    it "displays the admin in the stats" do
      expect(response["organization"]["stats"].select { |hash| hash["name"] == "users_count" }).to eq(["name" => "users_count", "value" => 1])
    end

    %w(
      processes_count
      comments_count
      assemblies_count
      conferences_count
      followers_count
      participants_count
    ).each do |stat|
      it {
        expect(response["organization"]["stats"].select { |hash| hash["name"] == stat }).to eq(["name" => stat, "value" => 0])
      }
    end
  end
end
