import template from './unsubscribe.html';
import './unsubscribe.scss';

angular.module('missionhubApp').component('unsubscribe', {
    controller: unsubscribeController,
    template: template,
    bindings: {
        token: '<',
        organizationId: '<',
        organizationName: '<',
    },
});

function unsubscribeController(httpProxy, $scope) {
    this.isUnsubscribed = false;
    this.isError = false;

    this.unsubscribe = async () => {
        try {
            await httpProxy.post('/unsubscriptions', {
                data: {
                    type: 'unsubscription',
                    attributes: {
                        organization_id: this.organizationId,
                        token: this.token,
                    },
                },
            });

            this.isUnsubscribed = true;
        } catch (error) {
            this.isError = true;
        }
        $scope.$apply();
    };
}
