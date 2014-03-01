Feature: Creating and saving drafts

Background:
  Given I am logged in as an admin user

Scenario: Creating a new draft
  When I go to the new draft page
   And I type up a new post
  Then I should see the newly saved draft
