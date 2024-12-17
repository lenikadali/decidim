# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/download_your_data_shared_examples"

module Decidim
  describe DownloadYourDataExporter do
    subject { DownloadYourDataExporter.new(user, "download-your-data", "CSV") }

    let(:user) { create(:user, organization:) }
    let(:organization) { create(:organization) }

    describe "#readme" do
      context "when the user has a debate" do
        let(:participatory_space) { create(:participatory_process, organization:) }
        let(:debates_component) { create(:debates_component, participatory_space:) }
        let!(:debate) { create(:debate, component: debates_component, author: user) }
        let(:help_definition_string) { "The debate title" }

        it_behaves_like "a download your data entity"
      end
    end
  end
end
