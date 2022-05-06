# frozen_string_literal: true
require "spec_helper"

RSpec.describe "Very basic searches"do
  solr = RSolr.connect(url: ENV["SOLR_URL"])

  let(:per_page) { 10 }
  let(:response) { solr.get("select", params: { q: search_term,  rows: per_page }) }
  let(:records) do (response.dig("response", "docs") || []).map { |doc|
    { id: doc.fetch("id"), title: doc.fetch("payload_ss") } }
  end

  context "Do an everything search" do
    let(:search_term) { "*" }

    it "should return all the records" do
      expect(records.count).to be >= 10;
    end
  end

  context "Do a search for a specific id" do
    let(:search_term) { "padig:SHI-vag97hr" }

    it "should return one record" do
      expect(records.count).to be == 1;
      expect(records.first[:id]).to eq search_term
    end
  end
end
