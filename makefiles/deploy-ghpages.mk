.PHONY: deploy.ghpages

COLOR_BLACK= ^[[0;30m
COLOR_GREEN = \e[0;32m
DEPLOY_DIR = deploy
BUILD_DIR = build
GIT_BRANCH = gh-pages

define mkdir_deploy_dir
    @if [ ! -d "$(PWD)/$(DEPLOY_DIR)/$(GIT_BRANCH)" ]; then mkdir $(PWD)/$(DEPLOY_DIR)/$(GIT_BRANCH); fi
endef

define git_init
    @cd $(PWD)/$(DEPLOY_DIR)/$(GIT_BRANCH) && rm -rf $(PWD)/$(DEPLOY_DIR)/$(GIT_BRANCH)/.git && git init
endef

define git_config
    $(eval GIT_USER_NAME := $(shell git config --list | grep 'user.name' | cut -d '=' -f 2))
    $(eval GIT_USER_EMAIL := $(shell git config --list | grep 'user.email' | cut -d '=' -f 2))
    @cd $(PWD)/$(DEPLOY_DIR)/$(GIT_BRANCH) && git config user.email "$(GIT_USER_EMAIL)"
    @cd $(PWD)/$(DEPLOY_DIR)/$(GIT_BRANCH) && git config user.name "$(GIT_USER_NAME)"
endef

define git_add_remote_repository
    @cd $(PWD)/$(DEPLOY_DIR)/$(GIT_BRANCH) && git remote add origin $1
endef

define create_branch_gh_pages
    @cd $(PWD)/$(DEPLOY_DIR)/$(GIT_BRANCH) && git checkout -b $(GIT_BRANCH)
endef

define copy_files_to_deploy
    @cp -r $(PWD)/$(DEPLOY_DIR)/$(BUILD_DIR)/* $(PWD)/$(DEPLOY_DIR)/$(GIT_BRANCH)
endef
define git_add
    @cd $(PWD)/$(DEPLOY_DIR)/$(GIT_BRANCH) && git add * && git status
endef

define create_commit
    $(eval MESSAGE := $(shell git log --pretty=format:"%s" | head -n 1))
    @cd $(PWD)/$(DEPLOY_DIR)/$(GIT_BRANCH) && git commit -m "$(MESSAGE)"
endef

define git_push
    @cd $(PWD)/$(DEPLOY_DIR)/$(GIT_BRANCH) && git push origin $(GIT_BRANCH) --force
endef

define clean_workspace
    @rm -rf $(PWD)/$(DEPLOY_DIR)/$(GIT_BRANCH)
endef

define show_deploy_url
    $(eval GIT_USER_NAME := $(shell git remote -v | grep origin | grep '(push)'| awk '{print $2}' | cut -d "/" -f 4))
    $(eval GIT_REPOSITORY_NAME := $(shell git remote -v | grep origin | grep '(push)'| awk '{print $2}' | cut -d "/" -f 5 | sed "s/.git//g" | sed "s/(push)//g"))
    @echo ""
    @echo "Publicado en: $(COLOR_BLACK)http://$(GIT_USER_NAME).github.io/$(GIT_REPOSITORY_NAME)"
    @echo ""
endef

deploy.ghpages: 
    $(eval REPOSITORY := $(shell git remote -v | grep origin | grep '(push)'| awk '{print $$2}'))
    $(call mkdir_deploy_dir)
    $(call git_init)
    $(call git_config)
    $(call git_add_remote_repository, $(REPOSITORY))
    $(call create_branch_gh_pages)
    $(call copy_files_to_deploy)
    $(call git_add)
    $(call create_commit)
    $(call git_push)
    $(call clean_workspace)
    $(call show_deploy_url)