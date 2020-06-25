angular
    .module('missionhubApp')
    .config((envServiceProvider) => {
        envServiceProvider.config({
            domains: {
                development: ['localhost', 'missionhub.local'],
                production: [
                    'missionhub.com',
                    'www.missionhub.com',
                    'mhub.cc',
                    'www.mhub.cc',
                ],
                productionCampusContacts: [
                    'campuscontacts.cru.org',
                    'ccontacts.app',
                ],
                staging: [
                    'stage.missionhub.com',
                    'stage.mhub.cc',
                    'new.missionhub.com',
                    '*.netlify.com',
                    '*.netlify.app',
                ],
                stagingCampusContacts: [
                    // These wildcards need to be the last domains so they don't override matches above
                    '*.campuscontacts.cru.org',
                    '*.ccontacts.app',
                    '*.d11caubtn1mk5o.amplifyapp.com',
                ],
            },
            vars: {
                development: {
                    apiUrl: 'https://campus-contacts-api-stage.cru.org/apis/v4',
                    theKeyClientId: '4921314596573158029',
                    facebookAppId: '264148437992398',
                    surveyLinkPrefix: 'http://localhost:8080/s/',
                    getMissionHub: 'http://localhost:8080',
                },
                staging: {
                    apiUrl: 'https://api-stage.missionhub.com/apis/v4',
                    theKeyClientId: '8138475243408077361',
                    facebookAppId: '233292170040365',
                    surveyLinkPrefix: 'https://stage.mhub.cc/s/',
                    getMissionHub: 'https://stage.missionhub.com',
                },
                stagingCampusContacts: {
                    apiUrl: 'https://campus-contacts-api-stage.cru.org/apis/v4',
                    theKeyClientId: '8138475243408077361',
                    facebookAppId: '264148437992398',
                    surveyLinkPrefix: 'https://stage.ccontacts.app/s/',
                    getMissionHub: 'https://stage.campuscontacts.cru.org',
                },
                production: {
                    apiUrl: 'https://api.missionhub.com/apis/v4',
                    theKeyClientId: '8480288430352167964',
                    facebookAppId: '233292170040365',
                    surveyLinkPrefix: 'https://mhub.cc/s/',
                    googleAnalytics: 'UA-325725-21',
                    getMissionHub: 'https://get.missionhub.com',
                },
                productionCampusContacts: {
                    apiUrl: 'https://campus-contacts-api.cru.org/apis/v4',
                    theKeyClientId: '8480288430352167964',
                    facebookAppId: '264148437992398',
                    surveyLinkPrefix: 'https://ccontacts.app/s/',
                    googleAnalytics: 'UA-325725-21',
                    getMissionHub: 'https://campuscontacts.cru.org',
                },
                defaults: {
                    theKeyUrl: 'https://thekey.me/cas',
                    googleAnalytics: 'UA-XXXXXX-XX',
                },
            },
        });

        // run the environment check, so the comprobation is made
        // before controllers and services are built
        envServiceProvider.check();
    })
    .config(($analyticsProvider) => {
        $analyticsProvider.firstPageview(false);
        $analyticsProvider.virtualPageviews(false);
    })
    .config((ngMdIconServiceProvider, $qProvider) => {
        /* eslint-disable max-len */
        ngMdIconServiceProvider
            .addViewBox('holySpirit', '0 0 48 48')
            .addViewBox('uncontactedPerson', '0 0 48 48')
            .addViewBox('assignedPeople', '0 0 48 48')
            .addViewBox('unassignedPerson', '0 0 48 48')
            .addViewBox('spiritualConversation', '0 0 48 48')
            .addViewBox('evangelism', '0 0 48 48')
            .addViewBox('personalDecision', '0 0 48 48')
            .addViewBox('discipleship', '0 0 48 48')
            .addViewBox('archive', '0 0 48 48')
            .addViewBox('addPerson', '0 0 48 48')
            .addViewBox('email', '0 0 48 48')
            .addViewBox('add', '0 0 48 48')
            .addViewBox('phone', '0 0 48 48')
            .addViewBox('close', '0 0 48 48')
            .addViewBox('edit', '0 0 48 48')
            .addViewBox('note', '0 0 48 48')
            .addShapes({
                edit:
                    '<g clip-path="url(#clip0)"><path d="M34.8984 18.375L32.6133 20.6602L27.3398 15.3867L29.625 13.1016L34.8984 18.375ZM25.582 17.1445L27.3398 18.9023L16.6172 29.625C16.0898 30.1523 16.0898 31.0313 16.6172 31.5586C16.793 31.7344 17.1445 31.9102 17.4961 31.9102C17.8477 31.9102 18.1992 31.7344 18.375 31.5586L29.0977 20.8359L30.8555 22.5938L19.2539 34.1953L12.9258 35.25L13.9805 28.9219L25.582 17.1445ZM38.0625 18.375C38.0625 18.0234 37.8867 17.6719 37.7109 17.4961L30.6797 10.4648C30.1523 9.9375 29.2734 9.9375 28.7461 10.4648L11.8711 27.1641C11.6953 27.3398 11.5195 27.6914 11.5195 27.8672L9.9375 36.4805C9.9375 36.832 9.9375 37.3594 10.2891 37.7109C10.6406 37.8867 10.9922 38.0625 11.168 38.0625H11.3438L19.957 36.6563C20.3086 36.6563 20.4844 36.4805 20.6602 36.3047L37.5352 19.4297C37.8867 19.0781 38.0625 18.7266 38.0625 18.375Z" fill="white"/></g><defs><clipPath id="clip0"><rect width="28.125" height="28.125" fill="white" transform="translate(9.9375 9.9375)"/></clipPath></defs>',
                unassignedPerson:
                    '<path d="M22.3125 24C27.2812 24 31.3125 19.9688 31.3125 15C31.3125 10.0312 27.2812 6 22.3125 6C17.3438 6 13.3125 10.0312 13.3125 15C13.3125 19.9688 17.3438 24 22.3125 24ZM22.3125 9C25.6219 9 28.3125 11.6906 28.3125 15C28.3125 18.3094 25.6219 21 22.3125 21C19.0031 21 16.3125 18.3094 16.3125 15C16.3125 11.6906 19.0031 9 22.3125 9Z" fill="currentColor"/><path d="M28.575 26.0625C27.3188 26.0625 26.5125 26.2781 25.6781 26.5031C24.7875 26.7469 23.8594 27 22.3125 27C20.7656 27 19.8375 26.7469 18.9469 26.5031C18.1125 26.2781 17.3156 26.0625 16.05 26.0625C13.2187 26.0625 10.4531 27.3281 8.84062 29.7281C7.875 31.1625 7.3125 32.8875 7.3125 34.7531V38.25C7.3125 40.3219 8.99062 42 11.0625 42H33.5625C35.6344 42 37.3125 40.3219 37.3125 38.25V34.7531C37.3125 32.8875 36.75 31.1625 35.7844 29.7281C34.1625 27.3281 31.4063 26.0625 28.575 26.0625ZM34.3125 38.25C34.3125 38.6625 33.975 39 33.5625 39H11.0625C10.65 39 10.3125 38.6625 10.3125 38.25V34.7531C10.3125 33.5531 10.6687 32.4 11.325 31.4062C12.3094 29.9437 14.0812 29.0625 16.05 29.0625C16.9406 29.0625 17.5875 29.2406 18.3188 29.4375C19.2656 29.7 20.3625 30 22.3125 30C24.2625 30 25.3594 29.7 26.3063 29.4375C27.0375 29.2406 27.6844 29.0625 28.575 29.0625C30.5438 29.0625 32.3063 29.9344 33.3 31.4062C33.9656 32.3906 34.3125 33.5531 34.3125 34.7531V38.25Z" fill="currentColor"/><rect x="37.3125" y="19.875" width="3.375" height="3.375" rx="1.6875" fill="currentColor"/><rect x="37.5" y="6.75" width="3" height="10.875" rx="1.5" fill="currentColor"/>',
                phone:
                    '<g clip-path="url(#clip0)"><path d="M45.7314 2.25998L36.2814 0.0756048C34.9032 -0.243145 33.4876 0.469355 32.9251 1.77248L28.5657 11.9444C28.0501 13.135 28.397 14.5412 29.4001 15.3662L34.4532 19.5006C31.2657 25.9881 25.9876 31.2756 19.4907 34.4631L15.3564 29.41C14.5314 28.4069 13.1251 28.06 11.9345 28.5756L1.77199 32.935C0.468866 33.4975 -0.243633 34.9037 0.0751165 36.2819L2.25012 45.7225C2.55949 47.0631 3.74074 48.0006 5.10949 48.0006C28.7532 48.0006 48.0001 28.8569 48.0001 5.10998C48.0001 3.74123 47.0626 2.55998 45.7314 2.25998ZM5.16574 45.0006L3.00949 35.6631L13.0782 31.3506L18.6564 38.1756C28.3689 33.6194 33.6282 28.3412 38.1657 18.6662L31.3407 13.0881L35.6532 3.01935L44.9907 5.1756C44.972 27.16 27.1501 44.9725 5.16574 45.0006Z" fill="currentColor"/></g><defs><clipPath id="clip0"><rect width="48" height="48" fill="white"/></clipPath></defs>',
                close:
                    '<rect width="3.02944" height="34.0812" rx="1.51472" transform="matrix(0.707344 0.70687 -0.707344 0.70687 34.9822 10.8926)" fill="currentColor"/><rect width="34.0812" height="3.02944" rx="1.51472" transform="matrix(-0.707344 -0.70687 0.707344 -0.70687 34.9822 37.1074)" fill="currentColor"/>',
                dashboard:
                    '<g transform="translate(-180, -24)">' +
                    '<path d="M203.78075,35.46975 L192.53075,24.21975 C192.23775,23.92675 191.76275,23.92675 191.46975,24.21975 L180.21975,35.46975 C179.92675,35.76275 179.92675,36.23775 180.21975,36.53075 C180.51275,36.82375 180.98775,36.82375 181.28075,36.53075 L182.25075,35.56075 L182.25075,47.24975 C182.25075,47.66375 182.58675,47.99975 183.00075,47.99975 L189.00075,47.99975 C189.41475,47.99975 189.75075,47.66375 189.75075,47.24975 L189.75075,39.74975 L194.25075,39.74975 L194.25075,47.24975 C194.25075,47.66375 194.58675,47.99975 195.00075,47.99975 L201.00075,47.99975 C201.41475,47.99975 201.75075,47.66375 201.75075,47.24975 L201.75075,35.56075 L202.71975,36.53075 C202.86675,36.67675 203.05775,36.74975 203.25075,36.74975 C203.44275,36.74975 203.63375,36.67675 203.78075,36.53075 C204.07375,36.23775 204.07375,35.76275 203.78075,35.46975 L203.78075,35.46975 Z M200.25075,34.06075 L200.25075,46.49975 L195.75075,46.49975 L195.75075,38.99975 C195.75075,38.58575 195.41475,38.24975 195.00075,38.24975 L189.00075,38.24975 C188.58675,38.24975 188.25075,38.58575 188.25075,38.99975 L188.25075,46.49975 L183.75075,46.49975 L183.75075,34.06075 L192.00075,25.81075 L200.25075,34.06075 Z" id="Fill-1"></path>' +
                    '</g>',
                discipleship:
                    '<rect x="15" y="6.375" width="3" height="16.5" rx="1.5" fill="currentColor"/><rect x="22.5" y="13.875" width="12" height="3" rx="1.5" transform="rotate(-180 22.5 13.875)" fill="currentColor"/><path d="M42 15H33V6C33 2.68594 30.3141 0 27 0H6C2.68594 0 0 2.68594 0 6V24C0 27.3141 2.68594 30 6 30H9V34.8731C9 35.5388 9.54656 36 10.1297 36C10.3556 36 10.5862 35.9306 10.7934 35.7778L18 31.6987V36C18 39.3141 20.6859 42 24 42H27L37.2066 47.7778C37.4137 47.9306 37.6453 48 37.8703 48C38.4534 48 39 47.5388 39 46.8731V42H42C45.3141 42 48 39.3141 48 36V21C48 17.6859 45.3141 15 42 15ZM12 31.6472V27H6C4.34625 27 3 25.6537 3 24V6C3 4.34625 4.34625 3 6 3H27C28.6537 3 30 4.34625 30 6V24C30 25.6537 28.6537 27 27 27H20.2097L12 31.6472ZM45 36C45 37.6537 43.6537 39 42 39H36V43.6472L27.7903 39H24C22.3463 39 21 37.6537 21 36V30H27C30.3141 30 33 27.3141 33 24V18H42C43.6537 18 45 19.3463 45 21V36Z" fill="currentColor"/>',
                assignedPeople:
                    '<path d="M40.875 28.5H37.125C36.9094 28.5 36.6938 28.5094 36.4781 28.5281C34.8469 26.9063 32.5781 26.0625 30.2625 26.0625C29.0062 26.0625 28.2 26.2781 27.3656 26.5031C26.475 26.7469 25.5469 27 24 27C22.4531 27 21.525 26.7469 20.6344 26.5031C19.8 26.2781 19.0031 26.0625 17.7375 26.0625C15.4219 26.0625 13.1531 26.9063 11.5125 28.5281C11.2969 28.5094 11.0906 28.5 10.875 28.5H7.125C3.19687 28.5 0 31.8656 0 36C0 36.825 0.675 37.5 1.5 37.5C2.325 37.5 3 36.825 3 36C3 33.5156 4.85625 31.5 7.125 31.5H9.6C9.20625 32.5031 9 33.6 9 34.7531V38.25C9 40.3219 10.6781 42 12.75 42H35.25C37.3219 42 39 40.3219 39 38.25V34.7531C39 33.6 38.7844 32.5031 38.4 31.5H40.875C43.1438 31.5 45 33.5156 45 36C45 36.825 45.675 37.5 46.5 37.5C47.325 37.5 48 36.825 48 36C48 31.8656 44.8031 28.5 40.875 28.5ZM36 38.25C36 38.6625 35.6625 39 35.25 39H12.75C12.3375 39 12 38.6625 12 38.25V34.7531C12 33.5531 12.3563 32.4 13.0125 31.4062C13.9969 29.9437 15.7687 29.0625 17.7375 29.0625C18.6281 29.0625 19.275 29.2406 20.0062 29.4375C20.9531 29.7 22.05 30 24 30C25.95 30 27.0469 29.7 27.9938 29.4375C28.725 29.2406 29.3719 29.0625 30.2625 29.0625C32.2312 29.0625 33.9938 29.9344 34.9875 31.4062C35.6531 32.3906 36 33.5531 36 34.7531V38.25Z" fill="currentColor"/><path d="M9 25.5C12.5625 25.5 15.5531 23.0156 16.3125 19.6781C17.8969 22.2656 20.7469 24 24 24C27.2531 24 30.1125 22.2656 31.6875 19.6781C32.4469 23.0156 35.4281 25.5 39 25.5C43.1438 25.5 46.5 22.1438 46.5 18C46.5 13.8562 43.1438 10.5 39 10.5C36.4875 10.5 34.2562 11.7375 32.8969 13.6406C32.2406 9.31875 28.5094 6 24 6C19.4906 6 15.7594 9.31875 15.1031 13.6406C13.7438 11.7375 11.5125 10.5 9 10.5C4.85625 10.5 1.5 13.8562 1.5 18C1.5 22.1438 4.85625 25.5 9 25.5ZM39 13.5C41.4844 13.5 43.5 15.5156 43.5 18C43.5 20.4844 41.4844 22.5 39 22.5C36.5156 22.5 34.5 20.4844 34.5 18C34.5 15.5156 36.5156 13.5 39 13.5ZM24 9C27.3094 9 30 11.6906 30 15C30 18.3094 27.3094 21 24 21C20.6906 21 18 18.3094 18 15C18 11.6906 20.6906 9 24 9ZM9 13.5C11.4844 13.5 13.5 15.5156 13.5 18C13.5 20.4844 11.4844 22.5 9 22.5C6.51562 22.5 4.5 20.4844 4.5 18C4.5 15.5156 6.51562 13.5 9 13.5Z" fill="currentColor"/>',
                uncontactedPerson:
                    '<path d="M26.8125 24C23.5594 24 20.7 22.2656 19.125 19.6781C18.3656 23.0156 15.3844 25.5 11.8125 25.5C7.66875 25.5 4.3125 22.1438 4.3125 18C4.3125 13.8562 7.66875 10.5 11.8125 10.5C14.325 10.5 16.5563 11.7375 17.9156 13.6406C18.5719 9.31875 22.3031 6 26.8125 6C31.7812 6 35.8125 10.0312 35.8125 15C35.8125 19.9688 31.7812 24 26.8125 24ZM11.8125 13.5C9.32812 13.5 7.3125 15.5156 7.3125 18C7.3125 20.4844 9.32812 22.5 11.8125 22.5C14.2969 22.5 16.3125 20.4844 16.3125 18C16.3125 15.5156 14.2969 13.5 11.8125 13.5ZM26.8125 9C23.5031 9 20.8125 11.6906 20.8125 15C20.8125 18.3094 23.5031 21 26.8125 21C30.1219 21 32.8125 18.3094 32.8125 15C32.8125 11.6906 30.1219 9 26.8125 9Z" fill="currentColor"/><path d="M9.9375 28.5H13.6875C13.9031 28.5 14.1187 28.5094 14.3344 28.5281C15.9656 26.9063 18.2344 26.0625 20.55 26.0625C21.8062 26.0625 22.6125 26.2781 23.4469 26.5031C24.3375 26.7469 25.2656 27 26.8125 27C28.3594 27 29.2875 26.7469 30.1781 26.5031C31.0125 26.2781 31.8094 26.0625 33.075 26.0625C35.9063 26.0625 38.6719 27.3281 40.2844 29.7281C41.25 31.1625 41.8125 32.8875 41.8125 34.7531V38.25C41.8125 40.3219 40.1344 42 38.0625 42H15.5625C13.4906 42 11.8125 40.3219 11.8125 38.25V34.7531C11.8125 33.6 12.0281 32.5031 12.4125 31.5H9.9375C7.66875 31.5 5.8125 33.5156 5.8125 36C5.8125 36.825 5.1375 37.5 4.3125 37.5C3.4875 37.5 2.8125 36.825 2.8125 36C2.8125 31.8656 6.00937 28.5 9.9375 28.5ZM14.8125 38.25C14.8125 38.6625 15.15 39 15.5625 39H38.0625C38.475 39 38.8125 38.6625 38.8125 38.25V34.7531C38.8125 33.5531 38.4563 32.4 37.8 31.4062C36.8156 29.9437 35.0438 29.0625 33.075 29.0625C32.1844 29.0625 31.5375 29.2406 30.8062 29.4375C29.8594 29.7 28.7625 30 26.8125 30C24.8625 30 23.7656 29.7 22.8187 29.4375C22.0875 29.2406 21.4406 29.0625 20.55 29.0625C18.5812 29.0625 16.8187 29.9344 15.825 31.4062C15.1594 32.3906 14.8125 33.5531 14.8125 34.7531V38.25Z" fill="currentColor"/><rect x="41.8125" y="19.875" width="3.375" height="3.375" rx="1.6875" fill="currentColor"/><rect x="42" y="6.75" width="3" height="10.875" rx="1.5" fill="currentColor"/>',
                holySpirit:
                    '<g clip-path="url(#clip0)"><path d="M34.5 15.0094C34.5 15.8344 35.175 16.5094 36 16.5094C36.825 16.5094 37.5 15.8344 37.5 15.0094C37.5 14.1844 36.825 13.5094 36 13.5094C35.175 13.5094 34.5 14.175 34.5 15.0094ZM36 6.00003C31.6407 6.00003 28.0032 9.10315 27.1782 13.2282C24.4407 9.7969 22.5938 5.70003 21.9282 1.29378C21.7313 0.0562783 20.1563 -0.478097 19.3125 0.515653C16.0032 4.42503 14.3438 8.81253 13.8094 11.9813C11.4375 9.69378 9.4969 6.9844 8.1469 3.91878C7.63128 2.73753 5.96253 2.69065 5.41878 3.85315C3.91878 7.04065 3.0469 10.5938 3.00003 14.3532C2.94378 18.375 3.91878 26.5594 13.3688 34.2094L1.29378 37.2282C0.140653 37.5188 -0.365597 38.8407 0.281278 39.8438C2.1469 42.7219 6.74065 47.5875 16.6688 48C17.925 48.0563 18.7969 47.3625 19.0313 47.1563L25.0219 42.0188H30C38.2875 42.0188 45 35.2969 45 27.0094V15L48 6.00003H36ZM19.6782 5.09065C21 9.80628 23.5407 14.0907 27 17.5594V18.75C23.1469 18.0563 19.6125 16.4719 16.5657 14.2688C16.8657 10.35 18.3844 7.16253 19.6782 5.09065V5.09065ZM42 14.5032V27.0188C42 33.6375 36.6188 39.0282 30 39.0282H23.9157C23.9157 39.0282 16.8657 45.0094 16.7907 45.0094C9.7969 44.7188 5.9344 41.9719 3.9094 39.675L19.9219 35.6719C15.4594 32.0438 5.85003 25.9125 6.00003 14.3907C6.02815 12.2625 6.3469 10.1813 6.96565 8.16565C14.6625 21.2063 28.125 22.1157 30 22.3313V15.0094C30 11.6907 32.6907 9.00003 36 9.00003H43.8375L42 14.5032Z" fill="currentColor"/></g><defs><clipPath id="clip0"><rect width="48" height="48" fill="white"/></clipPath></defs>',
                personalDecision:
                    '<rect x="22.5" y="14.8125" width="3" height="20.625" rx="1.5" fill="currentColor"/><rect x="31.5" y="23.8125" width="15" height="3" rx="1.5" transform="rotate(-180 31.5 23.8125)" fill="currentColor"/><path d="M43.3418 5.87792C38.2324 1.52792 30.5918 2.24979 25.848 7.14354L24.0012 9.05604L22.1543 7.15292C18.3293 3.19667 10.6137 0.815419 4.66053 5.87792C-1.22697 10.9029 -1.53635 19.9217 3.7324 25.3592L21.873 44.0904C22.4543 44.6904 23.223 44.9998 23.9918 44.9998C24.7605 44.9998 25.5293 44.6998 26.1105 44.0904L44.2512 25.3592C49.5387 19.9217 49.2293 10.9029 43.3418 5.87792V5.87792ZM42.1137 23.2779L24.0387 42.0092L5.88865 23.2779C2.28865 19.5654 1.53865 12.4873 6.61053 8.16542C11.748 3.77792 17.7855 6.95604 19.998 9.24354L24.0012 13.3779L28.0043 9.24354C30.1793 6.99354 36.273 3.80604 41.3918 8.16542C46.4543 12.4779 45.7137 19.556 42.1137 23.2779Z" fill="currentColor"/>',
                evangelism:
                    '<path d="M43.5656 45H43.875C44.4937 45 45 45.5063 45 46.125V46.875C45 47.4937 44.4937 48 43.875 48H10.5C6.35625 48 3 44.6438 3 40.5V7.5C3 3.35625 6.35625 0 10.5 0H42.75C43.9969 0 45 1.00312 45 2.25V36.75C45 37.6875 44.4188 38.4938 43.6031 38.8313C43.2656 40.3406 43.1906 43.1062 43.5656 45ZM15 36H42V3H15V36ZM6 37.5C7.25625 36.5625 8.8125 36 10.5 36H12V3H10.5C8.01562 3 6 5.01562 6 7.5V37.5ZM40.9031 45C40.6125 43.0875 40.6312 40.7625 40.9031 39H10.5C4.5 39 4.5 45 10.5 45H40.9031Z" fill="currentColor"/><rect x="27" y="9.1875" width="3" height="20.625" rx="1.5" fill="currentColor"/><rect x="36" y="18.1875" width="15" height="3" rx="1.5" transform="rotate(-180 36 18.1875)" fill="currentColor"/>',
                survey:
                    '<g transform="translate(-9, -11)">' +
                    '<path d="M30.5000771,34.2499969 L30.5000771,13.9999125 C30.5000771,13.5859108 30.1640757,13.2499094 29.750074,13.2499094 L26.5000604,13.2499094 L26.5000604,11.7499031 C26.5000604,11.3359014 26.164059,10.9999 25.7500573,10.9999 L16.7500198,10.9999 C16.3360181,10.9999 16.0000167,11.3359014 16.0000167,11.7499031 L16.0000167,13.2499094 L12.7500031,13.2499094 C12.3360014,13.2499094 12,13.5859108 12,13.9999125 L12,34.2499969 C12,34.6639986 12.3360014,35 12.7500031,35 L29.750074,35 C30.1640757,35 30.5000771,34.6639986 30.5000771,34.2499969 L30.5000771,34.2499969 Z M25.0000542,13.9999125 L25.0000542,15.4999187 L17.5000229,15.4999187 L17.5000229,13.9999125 L17.5000229,12.4999062 L25.0000542,12.4999062 L25.0000542,13.9999125 Z M29.0000708,33.4999937 L13.5000063,33.4999937 L13.5000063,14.7499156 L16.0000167,14.7499156 L16.0000167,16.2499219 C16.0000167,16.6639236 16.3360181,16.999925 16.7500198,16.999925 L25.7500573,16.999925 C26.164059,16.999925 26.5000604,16.6639236 26.5000604,16.2499219 L26.5000604,14.7499156 L29.0000708,14.7499156 L29.0000708,33.4999937 Z M16.0000167,19.9999375 C16.0000167,20.5529398 16.4480185,20.9999417 17.0000208,20.9999417 C17.5520231,20.9999417 18.000025,20.5529398 18.000025,19.9999375 C18.000025,19.4469352 17.5520231,18.9999333 17.0000208,18.9999333 C16.4480185,18.9999333 16.0000167,19.4469352 16.0000167,19.9999375 L16.0000167,19.9999375 Z M16.0000167,22.99995 C16.0000167,23.5529523 16.4480185,23.9999542 17.0000208,23.9999542 C17.5520231,23.9999542 18.000025,23.5529523 18.000025,22.99995 C18.000025,22.4469477 17.5520231,21.9999458 17.0000208,21.9999458 C16.4480185,21.9999458 16.0000167,22.4469477 16.0000167,22.99995 L16.0000167,22.99995 Z M16.0000167,25.9999625 C16.0000167,26.5529648 16.4480185,26.9999667 17.0000208,26.9999667 C17.5520231,26.9999667 18.000025,26.5529648 18.000025,25.9999625 C18.000025,25.4469602 17.5520231,24.9999583 17.0000208,24.9999583 C16.4480185,24.9999583 16.0000167,25.4469602 16.0000167,25.9999625 L16.0000167,25.9999625 Z M19.0000292,19.9999375 C19.0000292,20.4139392 19.3360306,20.7499406 19.7500323,20.7499406 L25.7500573,20.7499406 C26.164059,20.7499406 26.5000604,20.4139392 26.5000604,19.9999375 C26.5000604,19.5859358 26.164059,19.2499344 25.7500573,19.2499344 L19.7500323,19.2499344 C19.3360306,19.2499344 19.0000292,19.5859358 19.0000292,19.9999375 L19.0000292,19.9999375 Z M19.0000292,22.99995 C19.0000292,23.4139517 19.3360306,23.7499531 19.7500323,23.7499531 L25.7500573,23.7499531 C26.164059,23.7499531 26.5000604,23.4139517 26.5000604,22.99995 C26.5000604,22.5859483 26.164059,22.2499469 25.7500573,22.2499469 L19.7500323,22.2499469 C19.3360306,22.2499469 19.0000292,22.5859483 19.0000292,22.99995 L19.0000292,22.99995 Z M19.0000292,25.9999625 C19.0000292,26.4139642 19.3360306,26.7499656 19.7500323,26.7499656 L25.7500573,26.7499656 C26.164059,26.7499656 26.5000604,26.4139642 26.5000604,25.9999625 C26.5000604,25.5859608 26.164059,25.2499594 25.7500573,25.2499594 L19.7500323,25.2499594 C19.3360306,25.2499594 19.0000292,25.5859608 19.0000292,25.9999625 L19.0000292,25.9999625 Z"></path>' +
                    '</g>',
                add:
                    '<rect width="3.02943" height="34.0812" rx="1.51472" transform="matrix(0.000335152 1 -1 -0.000335152 41.0339 22.4971)" fill="currentColor"/><rect width="34.0812" height="3.02943" rx="1.51472" transform="matrix(-0.000335067 -1 1 0.000335236 22.4973 41.0342)" fill="currentColor"/>',
                addPerson:
                    '<g clip-path="url(#clip0)"><path fill-rule="evenodd" clip-rule="evenodd" d="M6.75 15C6.75 10.0312 10.7812 6 15.75 6C20.7188 6 24.75 10.0312 24.75 15C24.75 19.9688 20.7188 24 15.75 24C10.7812 24 6.75 19.9688 6.75 15ZM9.75 15C9.75 18.3094 12.4406 21 15.75 21C19.0594 21 21.75 18.3094 21.75 15C21.75 11.6906 19.0594 9 15.75 9C12.4406 9 9.75 11.6906 9.75 15ZM22.0125 26.0625C24.8438 26.0625 27.6 27.3281 29.2219 29.7281C30.1875 31.1625 30.75 32.8875 30.75 34.7531V38.25C30.75 40.3219 29.0719 42 27 42H4.5C2.42812 42 0.75 40.3219 0.75 38.25V34.7531C0.75 32.8875 1.3125 31.1625 2.27812 29.7281C3.89062 27.3281 6.65625 26.0625 9.4875 26.0625C10.7448 26.0625 11.5483 26.2807 12.38 26.5065C13.2724 26.7489 14.1973 27 15.75 27C17.3027 27 18.2276 26.7489 19.12 26.5065C19.9517 26.2807 20.7552 26.0625 22.0125 26.0625ZM27 39C27.4125 39 27.75 38.6625 27.75 38.25V34.7531C27.75 33.5531 27.4031 32.3906 26.7375 31.4062C25.7438 29.9344 23.9813 29.0625 22.0125 29.0625C21.1236 29.0625 20.4759 29.2398 19.7439 29.4403C18.7929 29.7006 17.6995 30 15.75 30C13.8005 30 12.7071 29.7006 11.7561 29.4403C11.0241 29.2398 10.3764 29.0625 9.4875 29.0625C7.51875 29.0625 5.74687 29.9437 4.7625 31.4062C4.10625 32.4 3.75 33.5531 3.75 34.7531V38.25C3.75 38.6625 4.0875 39 4.5 39H27Z" fill="currentColor"/><path d="M46.5012 16.5216L39.7716 16.5216L39.7716 23.2511C39.7716 23.6621 39.4335 24.0002 39.0225 24.0002L37.5243 24.0002C37.1133 24.0002 36.7753 23.6621 36.7753 23.2511L36.7753 16.5216H30.0457C29.6347 16.5216 29.2966 16.1835 29.2966 15.7725L29.2966 14.2743C29.2966 13.8633 29.6347 13.5252 30.0457 13.5252L36.7753 13.5252L36.7753 6.79569C36.7753 6.38469 37.1133 6.0466 37.5243 6.0466L39.0225 6.0466C39.4335 6.0466 39.7716 6.38469 39.7716 6.7957L39.7716 13.5252L46.5012 13.5252C46.9122 13.5252 47.2502 13.8633 47.2502 14.2743L47.2502 15.7725C47.2502 16.1835 46.9122 16.5216 46.5012 16.5216Z" fill="currentColor"/></g><defs><clipPath id="clip0"><rect width="48" height="48" fill="white"/></clipPath></defs></svg>',
                snooze:
                    '<g transform="translate(-1077, -481)">' +
                    '<path d="M1099.90924,488.566999 C1098.88024,486.670999 1097.33224,485.122999 1095.43324,484.090999 C1095.06724,483.893999 1094.61324,484.028999 1094.41624,484.391999 C1094.21924,484.755999 1094.35324,485.210999 1094.71724,485.408999 C1096.36024,486.301999 1097.70024,487.641999 1098.59124,489.282999 C1098.72624,489.532999 1098.98424,489.674999 1099.25124,489.674999 C1099.37124,489.674999 1099.49424,489.645999 1099.60724,489.583999 C1099.97124,489.385999 1100.10624,488.930999 1099.90924,488.566999 M1090.00024,485.999999 C1085.58924,485.999999 1082.00024,489.588999 1082.00024,493.999999 C1082.00024,498.410999 1085.58924,501.999999 1090.00024,501.999999 C1094.41124,501.999999 1098.00024,498.410999 1098.00024,493.999999 C1098.00024,489.588999 1094.41124,485.999999 1090.00024,485.999999 M1096.50024,493.999999 C1096.50024,497.583999 1093.58424,500.499999 1090.00024,500.499999 C1086.41624,500.499999 1083.50024,497.583999 1083.50024,493.999999 C1083.50024,490.415999 1086.41624,487.499999 1090.00024,487.499999 C1093.58424,487.499999 1096.50024,490.415999 1096.50024,493.999999 M1092.64724,495.897999 L1089.16224,495.897999 L1093.17724,491.881999 C1093.39224,491.667999 1093.45624,491.344999 1093.34124,491.064999 C1093.22424,490.784999 1092.95124,490.601999 1092.64724,490.601999 L1087.35224,490.601999 C1086.93824,490.601999 1086.60224,490.937999 1086.60224,491.351999 C1086.60224,491.765999 1086.93824,492.101999 1087.35224,492.101999 L1090.83724,492.101999 L1086.82224,496.117999 C1086.60724,496.332999 1086.54324,496.654999 1086.65924,496.934999 C1086.77524,497.215999 1087.04924,497.397999 1087.35224,497.397999 L1092.64724,497.397999 C1093.06124,497.397999 1093.39724,497.061999 1093.39724,496.647999 C1093.39724,496.233999 1093.06124,495.897999 1092.64724,495.897999 M1085.58424,484.391999 C1085.38624,484.026999 1084.93124,483.893999 1084.56724,484.090999 C1082.67024,485.120999 1081.12224,486.667999 1080.09124,488.566999 C1079.89324,488.930999 1080.02824,489.385999 1080.39224,489.583999 C1080.50624,489.645999 1080.62824,489.674999 1080.74924,489.674999 C1081.01524,489.674999 1081.27324,489.532999 1081.40924,489.282999 C1082.30224,487.639999 1083.64124,486.299999 1085.28224,485.408999 C1085.64624,485.211999 1085.78124,484.755999 1085.58424,484.391999"></path>' +
                    '</g>',
                dragHandle:
                    '<g transform="translate(4, 4)">' +
                    '<path d="M2,1 C2,0.448 1.552,0 1,0 C0.448,0 0,0.448 0,1 C0,1.552 0.448,2 1,2 C1.552,2 2,1.552 2,1 Z M2,5.6667 C2,5.1147 1.552,4.6667 1,4.6667 C0.448,4.6667 0,5.1147 0,5.6667 C0,6.2187 0.448,6.6667 1,6.6667 C1.552,6.6667 2,6.2187 2,5.6667 Z M2,15 C2,14.448 1.552,14 1,14 C0.448,14 0,14.448 0,15 C0,15.552 0.448,16 1,16 C1.552,16 2,15.552 2,15 Z M2,10.3333 C2,9.7813 1.552,9.3333 1,9.3333 C0.448,9.3333 0,9.7813 0,10.3333 C0,10.8853 0.448,11.3333 1,11.3333 C1.552,11.3333 2,10.8853 2,10.3333 Z M7,1 C7,0.448 6.552,0 6,0 C5.448,0 5,0.448 5,1 C5,1.552 5.448,2 6,2 C6.552,2 7,1.552 7,1 Z M7,5.6667 C7,5.1147 6.552,4.6667 6,4.6667 C5.448,4.6667 5,5.1147 5,5.6667 C5,6.2187 5.448,6.6667 6,6.6667 C6.552,6.6667 7,6.2187 7,5.6667 Z M7,15 C7,14.448 6.552,14 6,14 C5.448,14 5,14.448 5,15 C5,15.552 5.448,16 6,16 C6.552,16 7,15.552 7,15 Z M7,10.3333 C7,9.7813 6.552,9.3333 6,9.3333 C5.448,9.3333 5,9.7813 5,10.3333 C5,10.8853 5.448,11.3333 6,11.3333 C6.552,11.3333 7,10.8853 7,10.3333 Z M12,1 C12,0.448 11.552,0 11,0 C10.448,0 10,0.448 10,1 C10,1.552 10.448,2 11,2 C11.552,2 12,1.552 12,1 Z M12,5.6667 C12,5.1147 11.552,4.6667 11,4.6667 C10.448,4.6667 10,5.1147 10,5.6667 C10,6.2187 10.448,6.6667 11,6.6667 C11.552,6.6667 12,6.2187 12,5.6667 Z M12,15 C12,14.448 11.552,14 11,14 C10.448,14 10,14.448 10,15 C10,15.552 10.448,16 11,16 C11.552,16 12,15.552 12,15 Z M12,10.3333 C12,9.7813 11.552,9.3333 11,9.3333 C10.448,9.3333 10,9.7813 10,10.3333 C10,10.8853 10.448,11.3333 11,11.3333 C11.552,11.3333 12,10.8853 12,10.3333 Z"></path>' +
                    '</g>',
                visibilityOn:
                    '<g transform="translate(-1032.000000, -368)">' +
                    '<path d="M1053.86975,379.578 C1053.68675,379.31 1049.32375,373 1042.99975,373 C1036.67575,373 1032.31175,379.31 1032.12975,379.578 C1031.95675,379.833 1031.95675,380.167 1032.12975,380.422 C1032.31175,380.69 1036.67575,387 1042.99975,387 C1049.32375,387 1053.68675,380.69 1053.86975,380.422 C1054.04275,380.167 1054.04275,379.833 1053.86975,379.578 M1042.17275,374.588 C1042.44875,374.559 1042.71575,374.5 1042.99975,374.5 C1043.28375,374.5 1043.55175,374.559 1043.82775,374.588 C1045.63775,374.971 1046.99975,376.579 1046.99975,378.5 C1046.99975,380.705 1045.20575,382.5 1042.99975,382.5 C1040.79375,382.5 1038.99975,380.705 1038.99975,378.5 C1038.99975,376.578 1040.36275,374.971 1042.17275,374.588 M1052.31475,380 C1051.26275,381.355 1047.65675,385.5 1042.99975,385.5 C1038.35475,385.5 1034.73975,381.353 1033.68375,380 C1034.32775,379.171 1035.93275,377.306 1038.14075,375.977 C1037.74475,376.736 1037.49975,377.586 1037.49975,378.5 C1037.49975,381.532 1039.96675,384 1042.99975,384 C1046.03175,384 1048.49975,381.532 1048.49975,378.5 C1048.49975,377.589 1048.25575,376.741 1047.86175,375.984 C1050.06475,377.313 1051.67075,379.174 1052.31475,380"></path>' +
                    '</g>',
                visibilityOff:
                    '<g transform="translate(-1032, -436)">' +
                    '<path d="M1053.8705,447.578 C1053.6875,447.31 1049.3245,441 1043.0005,441 C1036.6765,441 1032.3125,447.31 1032.1305,447.578 C1031.9565,447.833 1031.9565,448.167 1032.1305,448.422 C1032.3125,448.69 1036.6765,455 1043.0005,455 C1049.3245,455 1053.6875,448.69 1053.8705,448.422 C1054.0435,448.167 1054.0435,447.833 1053.8705,447.578 M1042.1735,442.588 C1042.4495,442.559 1042.7165,442.5 1043.0005,442.5 C1043.8325,442.5 1044.6055,442.756 1045.2465,443.193 L1039.6935,448.746 C1039.2565,448.105 1039.0005,447.332 1039.0005,446.5 C1039.0005,444.578 1040.3635,442.971 1042.1735,442.588 M1047.0005,446.5 C1047.0005,448.705 1045.2065,450.5 1043.0005,450.5 C1042.1685,450.5 1041.3955,450.243 1040.7545,449.807 L1046.3075,444.254 C1046.7435,444.895 1047.0005,445.668 1047.0005,446.5 M1052.3155,448 C1051.2635,449.355 1047.6575,453.5 1043.0005,453.5 C1038.3555,453.5 1034.7405,449.353 1033.6845,448 C1034.3285,447.171 1035.9335,445.306 1038.1415,443.977 C1037.7455,444.736 1037.5005,445.586 1037.5005,446.5 C1037.5005,449.532 1039.9675,452 1043.0005,452 C1046.0325,452 1048.5005,449.532 1048.5005,446.5 C1048.5005,445.603 1048.2645,444.768 1047.8815,444.019 C1050.0735,445.343 1051.6745,447.178 1052.3155,448"></path>' +
                    '</g>',
                editOrder:
                    '<g transform="translate(-1079, -20)">' +
                    '<path d="M1100.7645,25.7955 C1101.0665,25.5105 1101.0805,25.0365 1100.7945,24.7345 L1096.5445,20.2345 C1096.5425,20.2325 1096.5395,20.2315 1096.5365,20.2295 C1096.4005,20.0895 1096.2115,19.9995 1096.0005,19.9995 C1095.7885,19.9995 1095.5995,20.0885 1095.4635,20.2295 C1095.4605,20.2315 1095.4575,20.2325 1095.4555,20.2345 L1091.2055,24.7345 C1090.9205,25.0365 1090.9345,25.5105 1091.2355,25.7955 C1091.5365,26.0795 1092.0105,26.0665 1092.2945,25.7655 L1095.2505,22.6365 L1095.2505,37.3635 L1092.2945,34.2355 C1092.0105,33.9345 1091.5365,33.9185 1091.2355,34.2055 C1090.9345,34.4895 1090.9205,34.9635 1091.2055,35.2645 L1095.4555,39.7645 C1095.4575,39.7665 1095.4605,39.7675 1095.4625,39.7695 C1095.5215,39.8305 1095.5935,39.8765 1095.6695,39.9155 C1095.6825,39.9215 1095.6925,39.9335 1095.7055,39.9395 C1095.7955,39.9775 1095.8955,39.9995 1096.0005,39.9995 C1096.1045,39.9995 1096.2035,39.9775 1096.2945,39.9395 C1096.3075,39.9335 1096.3175,39.9215 1096.3295,39.9155 C1096.4065,39.8765 1096.4785,39.8305 1096.5375,39.7695 C1096.5395,39.7675 1096.5425,39.7665 1096.5445,39.7645 L1100.7945,35.2645 C1101.0805,34.9635 1101.0665,34.4895 1100.7645,34.2055 C1100.4635,33.9185 1099.9895,33.9345 1099.7055,34.2355 L1096.7505,37.3635 L1096.7505,22.6365 L1099.7055,25.7655 C1099.8525,25.9215 1100.0505,25.9995 1100.2505,25.9995 C1100.4345,25.9995 1100.6195,25.9325 1100.7645,25.7955 M1089.0005,34.7495 C1089.0005,34.3355 1088.6645,33.9995 1088.2505,33.9995 L1079.7505,33.9995 C1079.3355,33.9995 1079.0005,34.3355 1079.0005,34.7495 C1079.0005,35.1635 1079.3355,35.4995 1079.7505,35.4995 L1088.2505,35.4995 C1088.6645,35.4995 1089.0005,35.1635 1089.0005,34.7495 M1089.0005,29.9995 C1089.0005,29.5855 1088.6645,29.2495 1088.2505,29.2495 L1079.7505,29.2495 C1079.3355,29.2495 1079.0005,29.5855 1079.0005,29.9995 C1079.0005,30.4135 1079.3355,30.7495 1079.7505,30.7495 L1088.2505,30.7495 C1088.6645,30.7495 1089.0005,30.4135 1089.0005,29.9995 M1089.0005,25.2495 C1089.0005,24.8355 1088.6645,24.4995 1088.2505,24.4995 L1079.7505,24.4995 C1079.3355,24.4995 1079.0005,24.8355 1079.0005,25.2495 C1079.0005,25.6645 1079.3355,25.9995 1079.7505,25.9995 L1088.2505,25.9995 C1088.6645,25.9995 1089.0005,25.6645 1089.0005,25.2495"></path>' +
                    '</g>',
                email:
                    '<path d="M43.5 6H4.5C2.01562 6 0 8.01562 0 10.5V37.5C0 39.9844 2.01562 42 4.5 42H43.5C45.9844 42 48 39.9844 48 37.5V10.5C48 8.01562 45.9844 6 43.5 6ZM4.5 9H43.5C44.325 9 45 9.675 45 10.5V14.3812C42.9469 16.1156 40.0125 18.5063 30.8812 25.7531C29.2969 27.0094 26.175 30.0375 24 30C21.825 30.0375 18.6938 27.0094 17.1188 25.7531C7.9875 18.5063 5.05312 16.1156 3 14.3812V10.5C3 9.675 3.675 9 4.5 9ZM43.5 39H4.5C3.675 39 3 38.325 3 37.5V18.2812C5.1375 20.0344 8.5125 22.7438 15.2531 28.0969C17.175 29.6344 20.5688 33.0188 24 33C27.4125 33.0281 30.7781 29.6719 32.7469 28.0969C39.4875 22.7438 42.8625 20.0344 45 18.2812V37.5C45 38.325 44.325 39 43.5 39Z" fill="currentColor"/>' +
                    '</g>',
                spiritualConversation:
                    '<g clip-path="url(#clip0)"><path d="M42.5531 48H2.44687C0.149994 48 -0.656256 45 0.571869 45H44.4281C45.6562 45 44.85 48 42.5531 48ZM48 23.9156C48.0469 28.9219 43.9969 33 39 33H36C36 37.9688 31.9687 42 27 42H15C10.0312 42 5.99999 37.9688 5.99999 33V16.125C5.99999 15.5063 6.50624 15 7.12499 15H38.8875C43.8375 15 47.9531 18.9563 48 23.9156ZM33 18H8.99999V33C8.99999 36.3094 11.6906 39 15 39H27C30.3094 39 33 36.3094 33 33V18ZM45 24C45 20.6906 42.3094 18 39 18H36V30H39C42.3094 30 45 27.3094 45 24Z" fill="currentColor"/><rect x="19.5" width="3" height="12" rx="1.5" fill="currentColor"/><rect x="13.5" y="5.25" width="3" height="6.75" rx="1.5" fill="currentColor"/><rect x="25.5" y="5.25" width="3" height="6.75" rx="1.5" fill="currentColor"/></g><defs><clipPath id="clip0"><rect width="48" height="48" fill="white"/></clipPath></defs>',
                note:
                    '<path d="M42 0H6C2.69063 0 0 2.69063 0 6V33C0 36.3094 2.69063 39 6 39H15V46.875C15 47.5406 15.5438 48 16.125 48C16.35 48 16.5844 47.9344 16.7906 47.775L28.5 39H42C45.3094 39 48 36.3094 48 33V6C48 2.69063 45.3094 0 42 0ZM45 33C45 34.65 43.65 36 42 36H27.4969L26.7 36.6L18 43.125V36H6C4.35 36 3 34.65 3 33V6C3 4.35 4.35 3 6 3H42C43.65 3 45 4.35 45 6V33ZM26.25 22.5H12.75C12.3375 22.5 12 22.8375 12 23.25V24.75C12 25.1625 12.3375 25.5 12.75 25.5H26.25C26.6625 25.5 27 25.1625 27 24.75V23.25C27 22.8375 26.6625 22.5 26.25 22.5ZM35.25 13.5H12.75C12.3375 13.5 12 13.8375 12 14.25V15.75C12 16.1625 12.3375 16.5 12.75 16.5H35.25C35.6625 16.5 36 16.1625 36 15.75V14.25C36 13.8375 35.6625 13.5 35.25 13.5Z" fill="currentColor"/>',
                archive:
                    '<path style=" stroke:none;fill-rule:evenodd;fill:rgb(100%,100%,100%);fill-opacity:1;" d="M 44 32.5 L 44 25.5 C 44 25.476562 43.988281 25.460938 43.988281 25.441406 C 43.984375 25.328125 43.953125 25.230469 43.925781 25.125 C 43.902344 25.039062 43.890625 24.953125 43.855469 24.875 C 43.816406 24.792969 43.753906 24.722656 43.699219 24.648438 C 43.640625 24.5625 43.585938 24.476562 43.507812 24.402344 C 43.492188 24.390625 43.484375 24.367188 43.46875 24.355469 L 36.96875 18.855469 C 36.699219 18.625 36.355469 18.5 36 18.5 L 24.074219 18.5 L 31.585938 10.660156 C 32.15625 10.0625 32.136719 9.117188 31.539062 8.542969 C 30.9375 7.96875 29.988281 7.988281 29.414062 8.589844 L 23.5 14.765625 L 23.5 1.5 C 23.5 0.671875 22.828125 0 22 0 C 21.171875 0 20.5 0.671875 20.5 1.5 L 20.5 14.765625 L 14.585938 8.589844 C 14.011719 7.988281 13.058594 7.96875 12.460938 8.542969 C 11.863281 9.117188 11.84375 10.0625 12.417969 10.660156 L 19.925781 18.5 L 8 18.5 C 7.644531 18.5 7.300781 18.625 7.03125 18.855469 L 0.53125 24.355469 C 0.515625 24.367188 0.507812 24.390625 0.492188 24.402344 C 0.414062 24.476562 0.359375 24.5625 0.296875 24.648438 C 0.246094 24.722656 0.183594 24.792969 0.148438 24.875 C 0.109375 24.953125 0.0976562 25.039062 0.0742188 25.125 C 0.046875 25.230469 0.015625 25.332031 0.0117188 25.441406 C 0.0117188 25.460938 0 25.476562 0 25.5 L 0 32.5 C 0 33.328125 0.671875 34 1.5 34 L 3 34 L 3 46.5 C 3 47.328125 3.671875 48 4.5 48 L 39.5 48 C 40.328125 48 41 47.328125 41 46.5 L 41 34 L 42.5 34 C 43.328125 34 44 33.328125 44 32.5 Z M 6 34 L 12 34 C 12 37.308594 14.691406 40 18 40 L 26 40 C 29.308594 40 32 37.308594 32 34 L 38 34 L 38 45 L 6 45 Z M 26 37 L 18 37 C 16.347656 37 15 35.652344 15 34 L 29 34 C 29 35.652344 27.652344 37 26 37 Z M 38.40625 24 L 5.59375 24 L 8.550781 21.5 L 35.453125 21.5 Z M 41 31 L 3 31 L 3 27 L 41 27 Z M 41 31 "/>',
            });

        /* eslint-enable max-len */

        $qProvider.errorOnUnhandledRejections(false);
    });
