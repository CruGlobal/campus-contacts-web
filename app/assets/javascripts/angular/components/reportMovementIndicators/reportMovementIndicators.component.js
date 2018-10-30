import template from './reportMovementIndicators.html';

angular.module('missionhubApp').component('reportMovementIndicators', {
    controller: reportMovementIndicatorsController,
    bindings: {
        orgId: '<',
    },
    template,
});

function reportMovementIndicatorsController($window, $state) {
    const ScreenEnum = (this.ScreenEnum = Object.freeze({
        SuggestedActions: 1,
        ReportMovementIndicators: 2,
    }));
    this.currentScreen = ScreenEnum.SuggestedActions;

    this.next = () => {
        switch (this.currentScreen) {
            case ScreenEnum.SuggestedActions:
                this.currentScreen = ScreenEnum.ReportMovementIndicators;
                break;
            case ScreenEnum.ReportMovementIndicators:
                $state.go('app.ministries.ministry.people', {
                    orgId: this.orgId,
                });
                break;
        }
        $window.scrollTo(0, 0);
    };
    this.previous = () => {
        switch (this.currentScreen) {
            case ScreenEnum.ReportMovementIndicators:
                this.currentScreen = ScreenEnum.SuggestedActions;
                break;
        }
        $window.scrollTo(0, 0);
    };
}
