Feature: Creating and saving drafts

Background:
  Given I am logged in as an admin user

Scenario: Creating a new draft
  When I go to the new draft page
   And I type up a new post
   And I save the draft
  Then I should see the newly saved draft

Scenario: Viewing a saved draft
  When I've saved a draft
  Then I should be able to see its contents

Scenario Outline: Saving a partial draft
  When I go to the new draft page
   And I type up a post with the <content> missing
   And I save the draft
  Then I should see an error message
   But the draft body should still be there

  Examples:
    | content    |
    | slug       |
    | title      |

Scenario: Editing an existing draft
  When I create a new draft
   And I view the draft for editing
   And I save the post with new content but no slug
  Then I should see an error about being unable to update
   But my new content should be there
