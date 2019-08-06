import i18next from 'i18next';

import template from './suggestedActions.html';

angular
    .module('missionhubApp')
    .component('reportMovementIndicatorsSuggestedActions', {
        controller: reportMovementIndicatorsSuggestedActionsController,
        bindings: {
            orgId: '<',
            next: '&',
        },
        template,
    });

function reportMovementIndicatorsSuggestedActionsController(httpProxy) {
    this.acceptedIds = new Set();
    this.rejectedIds = new Set();

    this.$onInit = () => {
        loadSuggestedActions(this.orgId);
    };

    const loadSuggestedActions = orgId => {
        this.loadingSuggestions = true;
        return httpProxy
            .post(
                '/movement_indicator_suggestions/fetch',
                { organization_id: orgId },
                {
                    errorMessage: i18next.t(
                        'movementIndicators:suggestedActions.errorLoadingSuggestedActions',
                    ),
                    params: {
                        include: 'person',
                        'fields[movement_indicator_suggestion]':
                            'id,person,reason,label,considered',
                        'fields[person]': 'full_name',
                        'fields[label]': 'name,i18n',
                        limit: 1000,
                    },
                },
            )
            .then(({ data }) => {
                this.loadingSuggestions = false;

                const { newSuggestions, previousSuggestions } = data.reduce(
                    (acc, action) => ({
                        newSuggestions: [
                            ...acc.newSuggestions,
                            ...(action.considered ? [] : [action]),
                        ],
                        previousSuggestions: [
                            ...acc.previousSuggestions,
                            ...(action.considered ? [action] : []),
                        ],
                    }),
                    { newSuggestions: [], previousSuggestions: [] },
                );

                this.newSuggestions = newSuggestions;
                this.previousSuggestions = previousSuggestions;
            });
    };

    this.saveSuggestedActions = () => {
        return httpProxy
            .post(
                '/movement_indicator_suggestions/bulk',
                {
                    accept_ids: [...this.acceptedIds],
                    reject_ids: [...this.rejectedIds],
                },
                {
                    errorMessage: i18next.t(
                        'movementIndicators:suggestedActions.errorSavingSuggestedActions',
                    ),
                },
            )
            .then(() => {
                this.next();
            });
    };

    this.handleSuggestionActionClick = (id, accept) => {
        const toggleSet = accept ? this.acceptedIds : this.rejectedIds;
        const removeSet = accept ? this.rejectedIds : this.acceptedIds;

        removeSet.delete(id);
        toggleSet.has(id) ? toggleSet.delete(id) : toggleSet.add(id);
    };

    this.handleAllClick = suggestions => {
        this.acceptedIds = new Set([
            ...this.acceptedIds,
            ...suggestions.map(({ id }) => id),
        ]);
        this.rejectedIds = new Set(
            [...this.rejectedIds].filter(id => !this.acceptedIds.has(id)),
        );
    };
}
