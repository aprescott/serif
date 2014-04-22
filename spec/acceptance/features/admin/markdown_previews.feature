@js
Feature: Ability to preview rendered versions of Markdown

Background:
  Given I am logged in as an admin user

Scenario Outline: When I press "Preview" on a post or draft, I should see rendered content
  When I press preview on a <post_or_draft> that has content
  Then I should see the rendered preview

  Examples:
    | post_or_draft |
    | post          |
    | draft         |
