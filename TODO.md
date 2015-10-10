# GENERAL
- [ ] Add options to settings of repositories to add users for reading (watchers)
- [x] Add options to settings of repositories to add users for writing (contributors)
- [ ] Add User Groups
- [ ] On the Dashboard, restrict the list of available repositories to the ones the current user has access to (currently all repos are visible).
- [x] Create an administration page for User Management (CRUD operations).
- [ ] Create an administration page for Resource Management.

# REPOSITORIES
- [x] Have a Settings view per repository
- [x] Have a Collaborator view per repository (adding, deleting, inviting)

# USERS
- [x] Have a settings page per user

# REPOSITORY MANAGEMENT
- [ ] Add max repo size to repository
- [ ] Add commit hook to keep track of git repo size (avoid having to recalculate dir size every time)
- [ ] Notify user by email if max repo size is exceeded
- [ ] Fail subsequent push actions after max repo size is exceeded (how can users fix this themselves?)
- [ ] Design garbage collection script (relating to `git gc`) to run in the background

# FILEBROWSER
- [x] Add vertical navbar menu with options specific to one repo.
- [x] Save repo specific settings in a Setting object.
- [x] Repo needs a description/tagline.
- [ ] Add a button to show the last commit message (off by default).
- [ ] Add the possibility to view a diff of two arbitrary revisions of a file (on file level, maybe using dropdowns). 
- [ ] Implement proze diffs for non-code files (server-side library: [daisydiff](https://code.google.com/p/daisydiff/))
- [x] Fix the File Browser not to show arbitrary files such as /etc/passwd.
- [x] Add a dropdown menu to the Filebrowser which available branches to browse.

# JGIT
- [x] Use the JGit library to extract a file tree from a particular branch of a repository (start with "master" branch).
- [x] Use JGit to create new Git repositories, both on disk and in ActiveRecord (use the create controller action).

# COMMIT HOOKS
- [ ] Add a method (using JGit?) to add commit hooks to git repositories.
- [ ] Write some basic commit hook scripts (e.g. mailer).
- [ ] Add an option to the create/edit views of repositories to add commit hooks to repositories.

# VALIDATIONS & SANITIZATION
- [x] Repository name is unique for owner
- [ ] datadir config option has default characters
- [ ] remove `attr_accessible` from models, remove `attr_accessible` gem, and replace with Strong Parameters. See http://www.sitepoint.com/rails-4-quick-look-strong-parameters/

# SYNCHRONIZATION
- [ ] Work out a way to update the 'updated-at' field of a repository in ActiveRecord each time a commit is made through the git servlet.

# AUTHENTICATION
- [x] Configure the Devise gem to include OAUTH2 and OpenID authentication methods.
- [x] Add an administrator page to the interface in which different authentication schemes can be enabled (Google, Facebook, AD, LDAP).
- [ ] Add LDAP authorization
- [x] Use CanCanCan

# EMAIL
- [x] Set up an email mechanism (preferably using an existing gem or Rails built-in mailers).
- [x] Add an admin page to the interface to configure SMTP settings for the mailer. Save these settings on disk (preferably in one central config file).
- [ ] Design an invitation mechanism with which to add users (identified by email address) to repositories and let these users know about the invitation by email.

# CONFIG
- [x] Set up configuration options in database

# WIKI
- [x] Mount gollum as Rack application
- [x] Have one optional wiki per repository

# BUG TRACKER
- [ ] Implement bug tracker

# OTHER
- [ ] Write a method that returns an Array of all repositories that haven't been updated for X amount of time.
- [ ] Write a method that merges two user accounts together in a sensible way.
- [ ] Add content to README
- [x] Make AuthProxy rack middleware generic, and add an AuthProxy for wikis (gollum)
- [ ] Override Rails's default confirmation box with a bootstrap modal: http://lesseverything.com/blog/archives/2012/07/18/customizing-confirmation-dialog-in-rails/
