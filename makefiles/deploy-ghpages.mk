.PHONY: deploy.ghpages

COLOR_BLACK= ^[[0;30m
COLOR_GREEN = \e[0;32m

DEPLOY_DIR = deploy
BUILD_DIR = build
GIT_BRANCH = gh-pages
GIT_PERSONAL_TOKEN = 205ac32b631868ced9354511ed3ac0de41937ab7
GIT_BRANCH_DIR = $(PWD)/$(DEPLOY_DIR)/$(GIT_BRANCH)

define mkdir_deploy_dir
	@if [ ! -d "$(GIT_BRANCH_DIR)" ]; then mkdir $(GIT_BRANCH_DIR); fi
endef

define git_init
	@cd $(GIT_BRANCH_DIR) && \
	 rm -rf $(GIT_BRANCH_DIR)/.git && \
	 git init
endef

define git_config
 	$(eval GIT_USER_NAME := $(shell git log --pretty=format:"%an" | head -n 1))
	$(eval GIT_USER_EMAIL := $(shell git log --pretty=format:"%ae" | head -n 1))
	@cd $(GIT_BRANCH_DIR) && \
	 git config user.email "$(GIT_USER_EMAIL)" && \
	 git config user.name "$(GIT_USER_NAME)"
endef

define git_add_remote_repository
	$(eval GIT_REPOSITORY_REMOTE := $(shell echo $1 | sed 's%https://%https://$(GIT_PERSONAL_TOKEN)@%g'))
	@cd $(GIT_BRANCH_DIR) && \
	 git remote add origin $(GIT_REPOSITORY_REMOTE)
endef

define create_branch_gh_pages
	@cd $(GIT_BRANCH_DIR) && \
	 git checkout -b $(GIT_BRANCH)
endef

define copy_files_to_deploy
	@cp -r $(PWD)/$(DEPLOY_DIR)/$(BUILD_DIR)/* $(GIT_BRANCH_DIR)
endef

define git_add
	@cd $(GIT_BRANCH_DIR) && \
	 git add * && \
	 git status
endef

define create_commit
	$(eval MESSAGE := $(shell git log --pretty=format:"%s" | head -n 1))
	@cd $(GIT_BRANCH_DIR) && \
	 git commit -m "$(MESSAGE)"
endef

define git_push
	@cd $(GIT_BRANCH_DIR) && \
	 git push origin $(GIT_BRANCH) --force
endef

define clean_workspace
	@rm -rf $(GIT_BRANCH_DIR)
endef

define show_deploy_url
	$(eval GIT_USER_NAME := $(shell git remote -v | grep origin | grep '(push)'| awk '{print $2}' | cut -d "/" -f 4))
	$(eval GIT_REPOSITORY_NAME := $(shell git remote -v | grep origin | grep '(push)'| awk '{print $2}' | cut -d "/" -f 5 | sed "s/.git//g" | sed "s/(push)//g"))
	@echo ""
	@echo "Publicado en: http://$(GIT_USER_NAME).github.io/$(GIT_REPOSITORY_NAME)"
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