import i18next from 'i18next';

import insightsUpdateIcon from '../../../../../src/communityInsights/assets/icons/insights-update-icon.svg';

angular
    .module('missionhubApp')
    .factory('insightsUpdateModalService', insightsUpdateModalService);

function insightsUpdateModalService($uibModal) {
    return {
        createModal: async () => {
            const confirmModal = $uibModal.open({
                component: 'insightsUpdateModal',
                resolve: {
                    title: () => i18next.t('insights:insightsUpdateTitle'),
                    paragraphs: () => [
                        i18next.t('insights:insightsUpdateContent'),
                    ],
                    icon: () => insightsUpdateIcon,
                },
                keyboard: false,
                windowClass: 'pivot_theme',
                backdrop: 'static',
            });

            try {
                await confirmModal.result;
                localStorage.setItem('confirmedInsightsUpdate', true);
            } catch (err) {}
        },
        checkModalConfirmation: () => {
            return localStorage.getItem('confirmedInsightsUpdate');
        },
    };
}
