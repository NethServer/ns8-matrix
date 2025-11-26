<!--
  Copyright (C) 2023 Nethesis S.r.l.
  SPDX-License-Identifier: GPL-3.0-or-later
-->
<template>
  <cv-grid fullWidth>
    <cv-row>
      <cv-column class="page-title">
        <h2>{{ $t("settings.title") }}</h2>
      </cv-column>
    </cv-row>
    <cv-row v-if="error.getConfiguration">
      <cv-column>
        <NsInlineNotification
          kind="error"
          :title="$t('action.get-configuration')"
          :description="error.getConfiguration"
          :showCloseButton="false"
        />
      </cv-column>
    </cv-row>
    <cv-row>
      <cv-column>
        <cv-tile light>
          <cv-form @submit.prevent="configureModule">
            <cv-text-input
              :label="$t('settings.synapse_domain_name')"
              v-model="synapse_domain_name"
              :placeholder="$t('settings.synapse_domain_placeholder')"
              :disabled="loading.getConfiguration || loading.configureModule"
              :invalid-message="error.synapse_domain_name"
              ref="synapse_domain_name"
            ></cv-text-input>
            <cv-text-input
              :label="$t('settings.element_domain_name')"
              v-model="element_domain_name"
              :placeholder="$t('settings.element_domain_placeholder')"
              :disabled="loading.getConfiguration || loading.configureModule"
              :invalid-message="error.element_domain_name"
              ref="element_domain_name"
            ></cv-text-input>
            <cv-text-input
              :label="$t('settings.cinny_domain_name')"
              v-model="cinny_domain_name"
              :placeholder="$t('settings.cinny_domain_placeholder')"
              :disabled="loading.getConfiguration || loading.configureModule"
              :invalid-message="error.cinny_domain_name"
              ref="cinny_domain_name"
            ></cv-text-input>
            <NsComboBox
              v-model.trim="dex_ldap_domain"
              :autoFilter="true"
              :autoHighlight="true"
              :title="$t('settings.dex_ldap_domain')"
              :label="$t('settings.choose_dex_ldap_domain')"
              :options="domains_list"
              :acceptUserInput="false"
              :showItemType="true"
              :invalid-message="$t(error.dex_ldap_domain)"
              :disabled="loading.getConfiguration || loading.configureModule"
              tooltipAlignment="start"
              tooltipDirection="top"
              ref="dex_ldap_domain"
            >
              <template slot="tooltip">
                {{ $t("settings.choose_the_dex_ldap_domain_to_use") }}
              </template>
            </NsComboBox>
            <cv-text-input
              :label="$t('settings.mail_from')"
              v-model="mail_from"
              :placeholder="$t('settings.mail_from_placeholder')"
              :disabled="loading.getConfiguration || loading.configureModule"
              :invalid-message="error.mail_from"
              ref="mail_from"
            ></cv-text-input>
            <NsToggle
              value="letsEncrypt"
              :label="core.$t('apps_lets_encrypt.request_https_certificate')"
              v-model="isLetsEncryptEnabled"
              :disabled="loading.getConfiguration || loading.configureModule"
              class="mg-bottom"
            >
              <template #tooltip>
                <div class="mg-bottom-sm">
                  {{ core.$t("apps_lets_encrypt.lets_encrypt_tips") }}
                </div>
                <div class="mg-bottom-sm">
                  <cv-link @click="goToCertificates">
                    {{ core.$t("apps_lets_encrypt.go_to_tls_certificates") }}
                  </cv-link>
                </div>
              </template>
              <template slot="text-left">{{
                $t("settings.disabled")
              }}</template>
              <template slot="text-right">{{
                $t("settings.enabled")
              }}</template>
            </NsToggle>
			      <cv-toggle
              value="enableElement"
              :label="$t('settings.enableElement')"
              v-model="enableElement"
              :disabled="loading.getConfiguration || loading.configureModule"
              class="mg-bottom"
            >
              <template slot="text-left">{{
                $t("settings.disabled")
              }}</template>
              <template slot="text-right">{{
                $t("settings.enabled")
              }}</template>
            </cv-toggle>
			      <cv-toggle
              value="enableCinny"
              :label="$t('settings.enableCinny')"
              v-model="enableCinny"
              :disabled="loading.getConfiguration || loading.configureModule"
              class="mg-bottom"
            >
              <template slot="text-left">{{
                $t("settings.disabled")
              }}</template>
              <template slot="text-right">{{
                $t("settings.enabled")
              }}</template>
            </cv-toggle>
            <cv-toggle
              value="enableSSO"
              :label="$t('settings.enableSSO')"
              v-model="enableSSO"
              :disabled="loading.getConfiguration || loading.configureModule"
              class="mg-bottom"
            >
              <template slot="text-left">{{
                $t("settings.disabled")
              }}</template>
              <template slot="text-right">{{
                $t("settings.enabled")
              }}</template>
            </cv-toggle>
            <cv-row v-if="error.configureModule">
              <cv-column>
                <NsInlineNotification
                  kind="error"
                  :title="$t('action.configure-module')"
                  :description="error.configureModule"
                  :showCloseButton="false"
                />
              </cv-column>
            </cv-row>
            <NsButton
              kind="primary"
              :icon="Save20"
              :loading="loading.configureModule"
              :disabled="loading.getConfiguration || loading.configureModule"
              >{{ $t("settings.save") }}
            </NsButton>
          </cv-form>
        </cv-tile>
      </cv-column>
    </cv-row>
  </cv-grid>
</template>

<script>
import to from "await-to-js";
import { mapState } from "vuex";
import {
  QueryParamService,
  UtilService,
  TaskService,
  IconService,
  PageTitleService,
} from "@nethserver/ns8-ui-lib";

export default {
  name: "Settings",
  mixins: [
    TaskService,
    IconService,
    UtilService,
    QueryParamService,
    PageTitleService,
  ],
  pageTitle() {
    return this.$t("settings.title") + " - " + this.appName;
  },
  data() {
    return {
      q: {
        page: "settings",
      },
      urlCheckInterval: null,
      synapse_domain_name: "",
      element_domain_name: "",
      cinny_domain_name: "",
      domains_list: [],
      dex_ldap_domain: "",
      mail_from: "",
      isLetsEncryptEnabled: false,
	    enableElement: false,
	    enableCinny: false,
      enableSSO: false,
      loading: {
        getConfiguration: false,
        configureModule: false,
      },
      error: {
        getConfiguration: "",
        configureModule: "",
        synapse_domain_name: "",
        element_domain_name: "",
        cinny_domain_name: "",
        dex_ldap_domain: "",
        mail_from: "",
        lets_encrypt: "",
		    enableElement: "",
		    enableCinny: "",
        enableSSO: "",
      },
    };
  },
  computed: {
    ...mapState(["instanceName", "core", "appName"]),
  },
  beforeRouteEnter(to, from, next) {
    next((vm) => {
      vm.watchQueryData(vm);
      vm.urlCheckInterval = vm.initUrlBindingForApp(vm, vm.q.page);
    });
  },
  beforeRouteLeave(to, from, next) {
    clearInterval(this.urlCheckInterval);
    next();
  },
  created() {
    this.getConfiguration();
  },
  methods: {
    goToCertificates() {
      this.core.$router.push("/settings/tls-certificates");
    },
    async getConfiguration() {
      this.loading.getConfiguration = true;
      this.error.getConfiguration = "";
      const taskAction = "get-configuration";
      const eventId = this.getUuid();

      // register to task error
      this.core.$root.$once(
        `${taskAction}-aborted-${eventId}`,
        this.getConfigurationAborted
      );

      // register to task completion
      this.core.$root.$once(
        `${taskAction}-completed-${eventId}`,
        this.getConfigurationCompleted
      );

      const res = await to(
        this.createModuleTaskForApp(this.instanceName, {
          action: taskAction,
          extra: {
            title: this.$t("action." + taskAction),
            isNotificationHidden: true,
            eventId,
          },
        })
      );
      const err = res[0];

      if (err) {
        console.error(`error creating task ${taskAction}`, err);
        this.error.getConfiguration = this.getErrorMessage(err);
        this.loading.getConfiguration = false;
        return;
      }
    },
    getConfigurationAborted(taskResult, taskContext) {
      console.error(`${taskContext.action} aborted`, taskResult);
      this.error.getConfiguration = this.$t("error.generic_error");
      this.loading.getConfiguration = false;
    },
    getConfigurationCompleted(taskContext, taskResult) {
      this.loading.getConfiguration = false;
      const config = taskResult.output;

      // Set configuration fields
      this.synapse_domain_name = config.synapse_domain_name || "";
      this.element_domain_name = config.element_domain_name || "";
      this.cinny_domain_name = config.cinny_domain_name || "";
      this.domains_list = config.domains_list;
      this.mail_from = config.mail_from || "";
      this.isLetsEncryptEnabled = config.lets_encrypt;
	    this.enableElement = config.enable_element;
	    this.enableCinny = config.enable_cinny;
      this.enableSSO = config.enable_sso;

      // force to reload value after dom update
      this.$nextTick(() => {
        this.dex_ldap_domain = config.dex_ldap_domain;
      });

      // Focus first configuration field
      this.focusElement("synapse_domain_name");
    },
    validateConfigureModule() {
      this.clearErrors(this);
      let isValidationOk = true;

      // Validate synapse domain name
      if (!this.synapse_domain_name) {
        this.error.synapse_domain_name = this.$t("common.required");
        if (isValidationOk) {
          this.focusElement("synapse_domain_name");
          isValidationOk = false;
        }
      }

      // Validate element domain name
      if (!this.element_domain_name) {
        this.error.element_domain_name = this.$t("common.required");
        if (isValidationOk) {
          this.focusElement("element_domain_name");
          isValidationOk = false;
        }
      }

      // Validate cinny domain name
      if (!this.cinny_domain_name) {
        this.error.cinny_domain_name = this.$t("common.required");
        if (isValidationOk) {
          this.focusElement("cinny_domain_name");
          isValidationOk = false;
        }
      }

      // Validate ldap domain
      if (!this.dex_ldap_domain) {
        this.error.dex_ldap_domain = this.$t("settings.required");

        if (isValidationOk) {
          this.focusElement("dex_ldap_domain");
          isValidationOk = false;
        }
      }

      return isValidationOk;
    },
    configureModuleValidationFailed(validationErrors) {
      this.loading.configureModule = false;
      let focusAlreadySet = false;

      for (const validationError of validationErrors) {
        const field = validationError.field;

        if (field !== "(root)") {
          // set i18n error message
          this.error[field] = this.$t("settings." + validationError.error);

          if (!focusAlreadySet) {
            this.focusElement(field);
            focusAlreadySet = true;
          }
        }
      }
    },
    async configureModule() {
      const isValidationOk = this.validateConfigureModule();
      if (!isValidationOk) {
        return;
      }

      this.loading.configureModule = true;
      const taskAction = "configure-module";
      const eventId = this.getUuid();

      // register to task error
      this.core.$root.$once(
        `${taskAction}-aborted-${eventId}`,
        this.configureModuleAborted
      );

      // register to task validation
      this.core.$root.$once(
        `${taskAction}-validation-failed-${eventId}`,
        this.configureModuleValidationFailed
      );

      // register to task completion
      this.core.$root.$once(
        `${taskAction}-completed-${eventId}`,
        this.configureModuleCompleted
      );

      const res = await to(
        this.createModuleTaskForApp(this.instanceName, {
          action: taskAction,
          data: {
            synapse_domain_name: this.synapse_domain_name,
            element_domain_name: this.element_domain_name,
            cinny_domain_name: this.cinny_domain_name,
            dex_ldap_domain: this.dex_ldap_domain,
            mail_from: this.mail_from,
            lets_encrypt: this.isLetsEncryptEnabled,
			      enable_element: this.enableElement,
			      enable_cinny: this.enableCinny,
            enable_sso: this.enableSSO,
          },
          extra: {
            title: this.$t("settings.configure_instance", {
              instance: this.instanceName,
            }),
            description: this.$t("common.processing"),
            eventId,
          },
        })
      );
      const err = res[0];

      if (err) {
        console.error(`error creating task ${taskAction}`, err);
        this.error.configureModule = this.getErrorMessage(err);
        this.loading.configureModule = false;
        return;
      }
    },
    configureModuleAborted(taskResult, taskContext) {
      console.error(`${taskContext.action} aborted`, taskResult);
      this.error.configureModule = this.$t("error.generic_error");
      this.loading.configureModule = false;
    },
    configureModuleCompleted() {
      this.loading.configureModule = false;

      // reload configuration
      this.getConfiguration();
    },
  },
};
</script>

<style scoped lang="scss">
@import "../styles/carbon-utils";
</style>
