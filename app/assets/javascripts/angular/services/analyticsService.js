angular.module('missionhubApp').factory('analyticsService', analyticsService);

function analyticsService($window, envService) {
    return {
        loadAdobe: () => {
            const url = envService.is('production')
                ? '//assets.adobedtm.com/3202ba9b02b459ee20779cfcd8e79eaf266be170/satelliteLib-b704a4f0b9d6babb4eac8ccc7c8a4fbf9e33f0fb.js'
                : '//assets.adobedtm.com/3202ba9b02b459ee20779cfcd8e79eaf266be170/satelliteLib-b704a4f0b9d6babb4eac8ccc7c8a4fbf9e33f0fb-staging.js';

            return function(d) {
                const id = 'adobe-analytics';
                const ref = d.getElementsByTagName('script')[0];

                if (d.getElementById(id)) {
                    return;
                }

                let js = d.createElement('script');
                js.id = id;
                js.async = true;
                js.src = url;

                ref.parentNode.insertBefore(js, ref);
            };
        },
        init: ssoUid => {
            $window.digitalData = {
                page: {
                    pageInfo: {
                        pageName: 'MissionHub',
                    },
                },
                user: [
                    {
                        profile: [
                            {
                                profileInfo: {
                                    ssoGuid: ssoUid,
                                },
                            },
                        ],
                    },
                ],
            };

            $window._satellite.pageBottom();
        },
        track: () => {
            $window._satellite && $window._satellite.track('page view');
        },
    };
}
