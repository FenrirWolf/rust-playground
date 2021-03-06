require 'spec_helper'
require 'support/editor'
require 'support/playground_actions'

RSpec.feature "Compiling to different formats", type: :feature, js: true do
  include PlaygroundActions

  before do
    visit '/'
    editor.set(code)
  end

  context "when AT&T syntax is selected" do
    before do
      click_on("Config")
      select("AT&T")
      click_on("Done")
    end

    scenario "compiling to assembly" do
      within('.header') { click_on("ASM") }

      within('.output-code') do
        # We demangle the symbols
        expect(page).to have_content 'playground::main:'

        expect(page).to have_content 'movq %rdi, %rax'
      end
    end
  end

  context "when Intel syntax is selected" do
    before do
      click_on("Config")
      select("Intel")
      click_on("Done")
    end

    scenario "compiling to assembly" do
      within('.header') { click_on("ASM") }

      within('.output-code') do
        # We demangle the symbols
        expect(page).to have_content 'playground::main:'

        expect(page).to have_content 'mov rax, rdi'
      end
    end
  end

  scenario "compiling to LLVM IR" do
    within('.header') { click_on("LLVM IR") }

    within('.output-code') do
      expect(page).to have_content 'ModuleID'
      expect(page).to have_content 'target datalayout'
      expect(page).to have_content 'target triple'
    end
  end

  scenario "compiling to MIR" do
    within('.header') { click_on("MIR") }

    within('.output-code') do
      expect(page).to have_content 'StorageLive'
      expect(page).to have_content 'StorageDead'
    end
  end

  scenario "compiling to WebAssembly" do
    within('.header') do
      choose_styled("Nightly")
      click_on("WASM")
    end

    within('.output-code') do
      expect(page).to have_content '(module'
      expect(page).to have_content '(block'
    end
  end

  context "when the code doesn't compile" do
    before { editor.set("fn main() {") }

    scenario "it shows the compilation error" do
      within('.header') { click_on("MIR") }

      within('.output-stderr') do
        expect(page).to have_content 'an un-closed delimiter'
      end
    end
  end

  def editor
    Editor.new(page)
  end

  def code
    <<~EOF
    fn main() {
        println!("Hello, world!");
    }
    EOF
  end
end
