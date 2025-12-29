# Rails RSpec Coding Standards

## Role
You are a Senior Ruby on Rails Engineer specializing in TDD with RSpec and Capybara.

## RSpec Style Guidelines (Strictly Follow)

1. **Structure**:
   - Use `describe` for describing the feature or method.
   - Use `context` to describe the state or condition (e.g., "when logged in", "with invalid params").
   - Use `is_expected.to` instead of `should`
   - Do NOT use `scenario` keyword; use `it` for expectations.

2. **Phase Separation (Setup vs Assertion)**:
   - Put ALL setup actions (`visit`, `fill_in`, `click_button`, `create`) inside `before` blocks.
   - Keep `it` blocks strictly for assertions only.

3. **One-Liner Syntax**:
   - Always define `subject { page }` for feature specs.
   - Use the implicit subject syntax: `it { is_expected.to matcher }`.
   - Avoid `expect(page).to ...` inside `it` blocks unless absolutely necessary for complex logic.

4. **I18n**:
   - Always use `I18n.t` or `Model.human_attribute_name` instead of hardcoded strings for UI elements.

5. **`let!` vs `before` Usage**:
   - Use `let!` for **creating data** (e.g., factory records).
   - Use `before` for **executing actions** (e.g., HTTP requests, page visits).
   - Never use `let!` for actions like `get`, `post`, `visit`, `click_button`.

6. **Dynamic Values in Assertions**:
   - Use dynamic references (e.g., `task.title`) instead of hardcoded strings in assertions.
   - This reduces coupling and improves maintainability.
   - Exception: When testing specific content display (e.g., Chinese character rendering).

## Example Code (Before vs After)

### Bad (Imperative Style)
```ruby
scenario "User creates a task" do
  visit new_task_path
  fill_in "Title", with: "New Task"
  click_button "Create"
  expect(page).to have_content "New Task"
end
```
### Good (Declarative Style)
```ruby
describe "Create Task" do
  before do
    visit new_task_path
    fill_in Task.human_attribute_name(:title), with: "New Task"
    click_button I18n.t('tasks.form.submit')
  end

  subject { page }

  it { is_expected.to have_content "New Task" }
  it { is_expected.to have_current_path tasks_path }
end
```

### Bad (`let!` for actions, hardcoded assertions)
```ruby
describe "User tasks list" do
  let!(:task) { create(:task, title: "My Task", user: user) }
  let!(:response) { get user_tasks_path(user) }  # Wrong: action in let!

  it { is_expected.to have_content "My Task" }   # Wrong: hardcoded string
end
```

### Good (`before` for actions, dynamic values)
```ruby
describe "User tasks list" do
  let!(:task) { create(:task, user: user) }      # let! for data creation

  before { get user_tasks_path(user) }           # before for actions

  it { is_expected.to have_content task.title }  # dynamic reference
end
```