require "system_test_helper"

class ComboboxTest < ApplicationSystemTestCase
  test "combobox is rendered" do
    visit root_path

    assert_selector "input[role=combobox]"
  end

  test "combobox is closed by default" do
    visit root_path

    assert_selector "input[aria-expanded=false]"
    assert_no_selector "li"
  end

  test "combobox can be opened" do
    visit root_path

    open_combobox

    assert_selector "input[aria-expanded=true]"
    assert_selector "ul[role=listbox]", id: "state-field-listbox"
    assert_selector "li[role=option]", text: "Alabama"
  end

  test "combobox can be opened by default if configured that way" do
    visit open_combobox_path

    assert_selector "input[aria-expanded=true]"
    assert_selector "ul[role=listbox]", id: "state-field-listbox"
    assert_selector "li[role=option]", text: "Alabama"
  end

  test "closing combobox by clicking outside" do
    visit root_path

    open_combobox

    assert_selector "input[aria-expanded=true]"
    find("body").click
    assert_selector "input[aria-expanded=false]"
    assert_no_selector "li"
  end

  test "closing combobox by focusing outside" do
    visit root_path

    open_combobox

    assert_selector "input[aria-expanded=true]"
    find("body").send_keys(:tab)
    assert_selector "input[aria-expanded=false]"
    assert_no_selector "li"
  end

  test "options can contain html" do
    visit html_combobox_path

    open_combobox

    assert_selector "ul[role=listbox]", id: "state-field-listbox"
    assert_selector "li[role=option] p", text: "Alabama"
  end

  test "options are filterable" do
    visit root_path

    open_combobox

    find("input[role=combobox]").send_keys("Flo")
    assert_selector "li[role=option]", text: "Florida"
    assert_no_selector "li[role=option]", text: "Alabama"
  end

  test "autocompletion" do
    visit html_combobox_path

    open_combobox

    find("input[role=combobox]").send_keys("Flor")
    assert_field "state-field-combobox", with: "Florida"
    assert_field "state-field", type: "hidden", with: "FL"
    assert_selector "li[role=option].selected", text: "Florida"

    find("input[role=combobox]").send_keys(:backspace)
    assert_field "state-field-combobox", with: "Flor"
    assert_field "state-field", type: "hidden", with: nil
    assert_no_selector "li[role=option].selected"
  end

  test "autocomplete only works when strings match from the very beginning, but the first option is still selected" do
    visit html_combobox_path

    open_combobox

    find("input[role=combobox]").send_keys("lor")
    assert_field "state-field-combobox", with: "lor"
    assert_field "state-field", type: "hidden", with: "FL"
    assert_selector "li[role=option].selected", text: "Florida"
  end

  test "pressing enter locks in the current selection, but editing the text field resets it" do
    visit html_combobox_path

    open_combobox

    find("input[role=combobox]").send_keys("lor", :enter)
    assert_selector "input[aria-expanded=false]"
    assert_field "state-field-combobox", with: "Florida"
    assert_field "state-field", type: "hidden", with: "FL"
    assert_no_selector "li[role=option].selected", text: "Florida" # because the list is closed

    find("input[role=combobox]").send_keys(:backspace)
    assert_selector "input[aria-expanded=true]"
    assert_field "state-field-combobox", with: "Florid"
    assert_field "state-field", type: "hidden", with: nil
    assert_no_selector "li[role=option].selected"
  end

  test "navigating with the arrow keys" do
    visit html_combobox_path

    open_combobox

    find("input[role=combobox]").send_keys(:down)
    assert_selector "li[role=option].selected", text: "Alabama"

    find("input[role=combobox]").send_keys(:down)
    assert_selector "li[role=option].selected", text: "Florida"

    find("input[role=combobox]").send_keys(:down)
    assert_selector "li[role=option].selected", text: "Michigan"

    find("input[role=combobox]").send_keys(:up)
    assert_selector "li[role=option].selected", text: "Florida"

    find("input[role=combobox]").send_keys(:up)
    assert_selector "li[role=option].selected", text: "Alabama"

    # wrap around
    find("input[role=combobox]").send_keys(:up)
    assert_selector "li[role=option].selected", text: "Missouri"

    find("input[role=combobox]").send_keys(:down)
    assert_selector "li[role=option].selected", text: "Alabama"

    # home and end keys
    find("input[role=combobox]").send_keys(:end)
    assert_selector "li[role=option].selected", text: "Missouri"

    find("input[role=combobox]").send_keys(:home)
    assert_selector "li[role=option].selected", text: "Alabama"
  end

  test "select option by clicking on it" do
    visit html_combobox_path

    open_combobox

    assert_field "state-field-combobox", with: nil
    assert_field "state-field", type: "hidden", with: nil

    find("li[role=option]", text: "Florida").click
    assert_selector "input[aria-expanded=false]"
    assert_field "state-field-combobox", with: "Florida"
    assert_field "state-field", type: "hidden", with: "FL"
  end

  test "combobox with prefilled value" do
    visit prefilled_combobox_path

    assert_selector "input[aria-expanded=false]"
    assert_field "state-field-combobox", with: "Michigan"
    assert_field "state-field", type: "hidden", with: "MI"

    open_combobox

    assert_selector "li[role=option].selected", text: "Michigan"
  end

  private
    def open_combobox
      find("input[role=combobox]").click
    end
end