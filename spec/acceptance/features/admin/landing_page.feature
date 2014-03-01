Feature: Admin landing page

Background:
  Given I am logged in as an admin user

Scenario: Admin landing page
  When I view the admin landing page
  Then I should see relevant summary information
