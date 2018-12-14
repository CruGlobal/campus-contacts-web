angular.module('missionhubApp').factory('analyticsService', analyticsService);

function analyticsService($window, envService, $location) {
    const setupGoogle = ssoUid => {
        ga('create', envService.read('googleAnalytics'), 'auto', {
            legacyCookieDomain: 'missionhub.com',
            allowLinker: true,
            sampleRate: 100,
            ...(ssoUid ? { userId: ssoUid } : {}),
        });

        ga(tracker => {
            ga('set', 'dimension2', tracker.get('clientId'));
        });

        ga('set', 'dimension3', ssoUid);
    };

    const setupAdobe = ssoUid => {
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

        $window._satellite && $window._satellite.pageBottom();
    };

    return {
        loadAdobeScript: () => {
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
            setupGoogle(ssoUid);
            setupAdobe(ssoUid);
        },
        track: transition => {
            const newState = transition.$to();
            const currentUrl = newState.path.reduce((acc, p) => {
                if (p.self.url === '^') return acc;

                const url = Object.entries(transition.params()).reduce(
                    (acc, [paramId, paramValue]) => {
                        return acc.replace(`:${paramId}`, paramValue);
                    },
                    p.self.url,
                );

                return acc + url;
            }, '');

            const fields = {
                page: currentUrl,
                location: envService.read('siteUrl') + currentUrl,
                title: newState.name,
            };

            ga('send', 'pageview', fields);
            $window._satellite && $window._satellite.track('page view');
        },
    };
}
