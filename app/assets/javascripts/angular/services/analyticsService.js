angular.module('missionhubApp').factory('analyticsService', analyticsService);

function analyticsService(
    $window,
    envService,
    $location,
    loggedInPerson,
    authenticationService,
) {
    const setupGoogle = ssoUid => {
        if (!angular.isFunction($window.ga)) return;

        $window.ga('create', envService.read('googleAnalytics'), 'auto', {
            legacyCookieDomain: 'missionhub.com',
            allowLinker: true,
            sampleRate: 100,
        });

        $window.ga(tracker => {
            $window.ga('set', 'dimension2', tracker.get('clientId'));
        });

        if (ssoUid) {
            $window.ga('set', 'dimension3', ssoUid);
            $window.ga('set', 'userId', ssoUid);
        }
    };

    const initAdobeData = () => {
        $window.digitalData = {
            page: {
                pageInfo: {
                    pageName: 'MissionHub',
                },
            },
        };
    };

    const setupAdobeData = (ssoUid, facebookId, grMasterPersonId) => {
        $window.digitalData = {
            page: {
                pageInfo: {
                    pageName: 'MissionHub',
                },
            },
            ...(ssoUid
                ? {
                      user: [
                          {
                              profile: [
                                  {
                                      profileInfo: {
                                          ssoGuid: ssoUid,
                                          grMasterPersonId: grMasterPersonId,
                                      },
                                      social: {
                                          facebook: facebookId,
                                      },
                                  },
                              ],
                          },
                      ],
                  }
                : {}),
        };
    };

    const loadAdobeScript = () => {
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
    };

    const setupAdobe = () => {
        $window._satellite && $window._satellite.pageBottom();
    };

    return {
        init: () => {
            if (!authenticationService.isTokenValid()) {
                initAdobeData();
                loadAdobeScript()(document);
                setupAdobe();
            } else {
                loggedInPerson
                    .loadOnce()
                    .then(({ thekey_uid, fb_uid, global_registry_mdm_id }) => {
                        setupGoogle(thekey_uid);
                        setupAdobeData(
                            thekey_uid,
                            fb_uid,
                            global_registry_mdm_id,
                        );
                        loadAdobeScript()(document);
                        setupAdobe();
                    });
            }
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
                location: `https://${$location.host()}/${currentUrl}`,
                title: newState.name,
            };

            if (angular.isFunction($window.ga))
                $window.ga('send', 'pageview', fields);

            $window._satellite && $window._satellite.track('page view');
        },
    };
}
