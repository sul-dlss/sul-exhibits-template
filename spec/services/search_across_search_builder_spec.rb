# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchAcrossSearchBuilder do
  subject(:search_builder) { described_class.new(scope) }

  let(:scope) do
    instance_double(Blacklight::SearchService,
                    blacklight_config: blacklight_config,
                    context: context,
                    search_state_class: nil)
  end
  let(:context) { { current_ability: current_ability } }
  let(:blacklight_config) { SearchAcrossController.blacklight_config.deep_copy }
  let(:user_params) { {} }
  let(:user) { create(:curator) }
  let(:current_ability) { Ability.new(user) }

  it 'restricts access to everything' do
    expect(subject[:fq]).to include SearchAcrossSearchBuilder::DENY_ALL
  end

  context 'with an ordinary user' do
    subject { search_builder.with(user_params).processed_parameters }

    let(:exhibit_public) { create(:exhibit, slug: 'exhibit-title-public', published: true) }
    let(:exhibit_private) { create(:exhibit, slug: 'exhibit-title-private', published: false) }

    before do
      # touch the exhibits to create them
      exhibit_public
      exhibit_private
    end

    it 'limits documents to public items in published exhibits' do
      actual = subject[:fq].last.split(Regexp.union(/ OR /, / AND /)).map { |x| x.tr('()', '') }
      expect(actual).to include 'spotlight_exhibit_slugs_ssim:exhibit-title-public'
      expect(actual).to include 'exhibit_exhibit-title-public_public_bsi:true'
      expect(actual).not_to include 'spotlight_exhibit_slugs_ssim:exhibit-title-private'
    end
  end

  context 'with a curator' do
    subject { search_builder.with(user_params).processed_parameters }

    let(:exhibit_public) { create(:exhibit, slug: 'exhibit-title-public', published: true) }
    let(:exhibit_private) { create(:exhibit, slug: 'exhibit-title-private', published: false) }
    let(:exhibit_curated) { create(:exhibit, slug: 'exhibit-title-curated', published: false) }

    before do
      # touch the exhibits to create them
      exhibit_public
      exhibit_private
      user.roles.create!(resource: exhibit_curated, role: :curator)
    end

    it 'allows them to see items in their unpublished exhibits' do
      actual = subject[:fq].last.split(Regexp.union(/ OR /, / AND /)).map { |x| x.tr('()', '') }

      expect(actual).to include 'spotlight_exhibit_slugs_ssim:exhibit-title-public'
      expect(actual).to include 'exhibit_exhibit-title-public_public_bsi:true'
      expect(actual).to include 'spotlight_exhibit_slugs_ssim:exhibit-title-curated'
      expect(actual).not_to include 'exhibit_exhibit-title-curated_public_bsi:true'
      expect(actual).not_to include 'spotlight_exhibit_slugs_ssim:exhibit-title-private'
    end
  end
end
