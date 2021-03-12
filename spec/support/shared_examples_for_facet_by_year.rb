# frozen_string_literal: true

RSpec.shared_examples 'provides_constraint_on_next_page_unknown' do
  it "provides a constraint on the next page" do
    expect(page).to have_content('Remove constraint Publication/Creation Date: Unknown')
    expect(page).not_to have_content('Llama Love')
    expect(page).not_to have_content('Newt Nutrition')
    expect(page).to have_content('Eagle Excellence')
  end
end

RSpec.shared_examples 'gets_all_possible_documents' do
  it "gets all available documents" do
    expect(page).to have_content('Llama Love')
    expect(page).to have_content('Newt Nutrition')
    expect(page).to have_content('Eagle Excellence')
  end
end
