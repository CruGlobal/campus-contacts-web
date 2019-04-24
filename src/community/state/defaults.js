import moment from 'moment';

export default {
    apolloClient: {
        __typename: 'ApolloClient',
        currentTab: 'MEMBERS',
        currentFilter: {
            __typename: 'currentFilter',
            key: '1W',
            startDate: moment()
                .subtract(1, 'week')
                .format('l'),
            endDate: moment().format('l'),
        },
        celebrations: {
            __typename: 'celebrations',
            data: [
                {
                    __typename: 'Data',
                    message:
                        'Leah Completed a Step of Faith with a Curious person',
                    user: 'Leah Brooks',
                    key: 'MESSAGE_1',
                },
                {
                    __typename: 'Data',
                    message:
                        'Leah Completed a Step of Faith with a Curious person',
                    user: 'Leah Brooks',
                    key: 'MESSAGE_2',
                },
                {
                    __typename: 'Data',
                    message:
                        'Leah Completed a Step of Faith with a Curious person',
                    user: 'Leah Brooks',
                    key: 'MESSAGE_3',
                },
                {
                    __typename: 'Data',
                    message:
                        'Leah Completed a Step of Faith with a Curious person',
                    user: 'Leah Brooks',
                    key: 'MESSAGE_4',
                },
            ],
        },
        stepsCompleted_default: {
            __typename: 'StepsCompleted',
            data: [
                {
                    __typename: 'Data',
                    x: '3/19/2019',
                    y: 21,
                },
                {
                    __typename: 'Data',
                    x: '3/20/2019',
                    y: 23,
                },
                {
                    __typename: 'Data',
                    x: '3/21/2019',
                    y: 24,
                },
                {
                    __typename: 'Data',
                    x: '3/22/2019',
                    y: 23,
                },
                {
                    __typename: 'Data',
                    x: '2/23/2019',
                    y: 25,
                },
                {
                    __typename: 'Data',
                    x: '3/24/2019',
                    y: 26,
                },
                {
                    __typename: 'Data',
                    x: '3/25/2019',
                    y: 28,
                },
            ],
        },
        stepsCompleted_1W: {
            __typename: 'StepsCompleted',
            data: [
                {
                    __typename: 'Data',
                    x: '3/19/2019',
                    y: 19,
                },
                {
                    __typename: 'Data',
                    x: '3/20/2019',
                    y: 24,
                },
                {
                    __typename: 'Data',
                    x: '3/21/2019',
                    y: 23,
                },
                {
                    __typename: 'Data',
                    x: '3/22/2019',
                    y: 25,
                },
                {
                    __typename: 'Data',
                    x: '2/23/2019',
                    y: 27,
                },
                {
                    __typename: 'Data',
                    x: '3/24/2019',
                    y: 23,
                },
                {
                    __typename: 'Data',
                    x: '3/25/2019',
                    y: 30,
                },
            ],
        },
        members_default: {
            __typename: 'Members',
            data: [
                {
                    __typename: 'Data',
                    stage: 'No Stage',
                    members: 10,
                    stepsAdded: 12,
                    stepsCompleted: 37,
                },
                {
                    __typename: 'Data',
                    stage: 'Not Sure',
                    members: 11,
                    stepsAdded: 34,
                    stepsCompleted: 37,
                },
                {
                    __typename: 'Data',
                    stage: 'Uninterested',
                    members: 12,
                    stepsAdded: 53,
                    stepsCompleted: 10,
                },
                {
                    __typename: 'Data',
                    stage: 'Curious',
                    members: 13,
                    stepsAdded: 23,
                    stepsCompleted: 34,
                },
                {
                    __typename: 'Data',
                    stage: 'Forgiven',
                    members: 14,
                    stepsAdded: 19,
                    stepsCompleted: 27,
                },
                {
                    __typename: 'Data',
                    stage: 'Growing',
                    members: 15,
                    stepsAdded: 11,
                    stepsCompleted: 25,
                },
                {
                    __typename: 'Data',
                    stage: 'Guiding',
                    members: 16,
                    stepsAdded: 21,
                    stepsCompleted: 34,
                },
            ],
        },
        members_1W: {
            __typename: 'Members',
            data: [
                {
                    __typename: 'Data',
                    stage: 'No Stage',
                    members: 11,
                    stepsAdded: 23,
                    stepsCompleted: 14,
                },
                {
                    __typename: 'Data',
                    stage: 'Not Sure',
                    members: 12,
                    stepsAdded: 12,
                    stepsCompleted: 51,
                },
                {
                    __typename: 'Data',
                    stage: 'Uninterested',
                    members: 13,
                    stepsAdded: 32,
                    stepsCompleted: 23,
                },
                {
                    __typename: 'Data',
                    stage: 'Curious',
                    members: 14,
                    stepsAdded: 12,
                    stepsCompleted: 31,
                },
                {
                    __typename: 'Data',
                    stage: 'Forgiven',
                    members: 15,
                    stepsAdded: 19,
                    stepsCompleted: 27,
                },
                {
                    __typename: 'Data',
                    stage: 'Growing',
                    members: 16,
                    stepsAdded: 21,
                    stepsCompleted: 29,
                },
                {
                    __typename: 'Data',
                    stage: 'Guiding',
                    members: 17,
                    stepsAdded: 12,
                    stepsCompleted: 43,
                },
            ],
        },
        stepsInfoPersonal: {
            __typename: 'stepsInfoPersonal',
            userStats: 20,
            numberStats: 120,
            peopleStats: 40,
        },
        stepsInfoSpiritual: {
            __typename: 'stepsInfoSpiritual',
            userStats: 2,
        },
        tabsContent: {
            __typename: 'tabsConfig',
            data: [
                {
                    __typename: 'Data',
                    title: 'PEOPLE/STEPS OF FAITH',
                    key: 'MEMBERS',
                    stats: '40 / 120',
                },
                {
                    __typename: 'Data',
                    title: 'STEPS COMPLETED',
                    key: 'STEPS_COMPLETED',
                    stats: '20',
                },
                {
                    __typename: 'Data',
                    title: 'PEOPLE MOVEMENT',
                    key: 'PEOPLE_MOVEMENT',
                    stats: '2',
                },
                {
                    __typename: 'Data',
                    title: '',
                    key: '',
                    stats: '',
                },
            ],
        },
    },
};
