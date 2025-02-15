# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Project search" do
  include Decidim::ComponentPathHelper

  subject { response.body }

  let(:component) { create(:budgets_component) }
  let(:participatory_space) { component.participatory_space }
  let(:organization) { participatory_space.organization }
  let(:filter_params) { {} }
  let(:resource_params) { { budget: } }

  let(:budget) { create(:budget, component:) }
  let(:budget2) { create(:budget, component:) }
  let!(:project1) do
    create(
      :project,
      :selected,
      budget:
    )
  end
  let!(:project2) do
    create(
      :project,
      :selected,
      budget:
    )
  end
  let!(:project3) do
    create(
      :project,
      budget:
    )
  end
  let!(:project4) { create(:project, budget: budget2) }
  let!(:project5) { create(:project, budget: budget2) }

  let(:request_path) { Decidim::EngineRouter.main_proxy(component).budget_projects_path(budget) }

  before do
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => component.organization.host }
    )
  end

  it_behaves_like "a resource search", :project
  it_behaves_like "a resource search with taxonomies", :project

  it "displays all projects within the budget without any filters" do
    expect(subject).to include(decidim_escape_translated(project1.title))
    expect(subject).to include(decidim_escape_translated(project2.title))
    expect(subject).to include(decidim_escape_translated(project3.title))
    expect(subject).not_to include(decidim_escape_translated(project4.title))
    expect(subject).not_to include(decidim_escape_translated(project5.title))
  end

  context "when searching by status" do
    let(:filter_params) { { with_any_status: status } }

    context "with the all statuses" do
      let(:status) { ["all"] }

      it "displays all projects" do
        expect(subject).to include(decidim_escape_translated(project1.title))
        expect(subject).to include(decidim_escape_translated(project2.title))
        expect(subject).to include(decidim_escape_translated(project3.title))
      end
    end

    context "and the status is selected" do
      let(:status) { ["selected"] }

      it "displays the selected projects" do
        expect(subject).to include(decidim_escape_translated(project1.title))
        expect(subject).to include(decidim_escape_translated(project2.title))
        expect(subject).not_to include(decidim_escape_translated(project3.title))
      end
    end

    context "and the status is not selected" do
      let(:status) { ["not_selected"] }

      it "displays the selected projects" do
        expect(subject).not_to include(decidim_escape_translated(project1.title))
        expect(subject).not_to include(decidim_escape_translated(project2.title))
        expect(subject).to include(decidim_escape_translated(project3.title))
      end
    end
  end

  describe "#index" do
    let(:url) { "http://#{component.organization.host + request_path}" }

    it "redirects to the index page" do
      get(
        url_to_root(request_path),
        params: {},
        headers: { "HOST" => component.organization.host }
      )
      expect(response["Location"]).to eq(url)
      expect(response).to have_http_status(:found)
    end
  end

  private

  def url_to_root(url)
    parts = url.split("/")
    parts[0..-2].join("/")
  end
end
