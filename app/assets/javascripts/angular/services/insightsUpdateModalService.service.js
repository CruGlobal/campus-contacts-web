import i18next from 'i18next';

angular
    .module('missionhubApp')
    .factory('insightsUpdateModalService', insightsUpdateModalService);

function insightsUpdateModalService($uibModal) {
    return {
        createModal: async () => {
            const confirmModal = $uibModal.open({
                component: 'iconModal',
                resolve: {
                    title: () => i18next.t('insights:insightsUpdateTitle'),
                    paragraphs: () => [
                        i18next.t('insights:insightsUpdateContent'),
                    ],
                    closeLabel: () => i18next.t('general.ok'),
                    dismissLabel: () => null,
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
