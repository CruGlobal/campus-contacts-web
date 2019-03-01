angular.module('missionhubApp').factory('analyticsService', analyticsService);

function analyticsService(
    $window,
    envService,
    $location,
    loggedInPerson,
    authenticationService,
) {
    const initGoogle = () => {
        if (!angular.isFunction($window.ga)) return;

        $window.ga('create', envService.read('googleAnalytics'), 'auto', {
            legacyCookieDomain: 'missionhub.com',
            allowLinker: true,
            sampleRate: 100,
        });

        $window.ga(tracker => {
            $window.ga('set', 'dimension2', tracker.get('clientId'));
        });
    };

    const setupGoogleData = ssoUid => {
        if (!angular.isFunction($window.ga)) return;

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

    const setupAuthenitcatedAnalyticData = () => {
        return loggedInPerson
            .loadOnce()
            .then(({ thekey_uid, fb_uid, global_registry_mdm_id }) => {
                setupGoogleData(thekey_uid);
                setupAdobeData(thekey_uid, fb_uid, global_registry_mdm_id);
            });
    };

    const loadScript = (url, id) => {
        return function(d) {
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

    const loadAdobeScript = () => {
        const url = envService.is('production')
            ? '//assets.adobedtm.com/launch-EN541f7d1d75de45f78e4e3881d6264bae.min.js'
            : '//assets.adobedtm.com/launch-ENe4ca7f50fed34edd995d7c6294e6b509-development.min.js';

        return loadScript(url, 'adobe-analytics');
    };

    const trackAdobe = () =>
        CustomEvent !== undefined &&
        $window.document
            .querySelector('body')
            .dispatchEvent(new CustomEvent('content: all pages'));

    return {
        init: () => {
            initAdobeData();
            initGoogle();
            loadAdobeScript()(document);

            if (authenticationService.isTokenValid()) {
                setupAuthenitcatedAnalyticData();
            }
        },
        setupAuthenitcatedAnalyticData: setupAuthenitcatedAnalyticData,
        clearAuthenticatedData: () => {
            initAdobeData();
            $window.ga('set', 'dimension3');
            $window.ga('set', 'userId');
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

            if (
                authenticationService.isTokenValid() &&
                !$window.digitalData.user
            ) {
                setupAuthenitcatedAnalyticData().then(() => {
                    trackAdobe();
                    angular.isFunction($window.ga) &&
                        $window.ga('send', 'pageview', fields);
                });
            } else {
                trackAdobe();
                angular.isFunction($window.ga) &&
                    $window.ga('send', 'pageview', fields);
            }
        },
    };
}
