import moment from 'moment';

export default {
    apolloClient: {
        __typename: 'ApolloClient',
        currentTab: 'MEMBERS',
        currentFilter: {
            __typename: 'currentFilter',
            key: '1W',
            startDate: moment().subtract(1, 'week').format('l'),
            endDate: moment().format('l')
        },
        stepsCompleted: {
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
                    __typename: 'Element',
                    x: '3/25/2019',
                    y: 28,
                },
            ],
        },
        members: {
            __typename: 'Members',
            data: [
                {
                    __typename: 'Data',
                    stage: 'No Stage',
                    members: 10,
                    stepsAdded: 25,
                    stepsCompleted: 17,
                },
                {
                    __typename: 'Data',
                    stage: 'Not Sure',
                    members: 10,
                    stepsAdded: 34,
                    stepsCompleted: 37,
                },
                {
                    __typename: 'Data',
                    stage: 'Uninterested',
                    members: 10,
                    stepsAdded: 53,
                    stepsCompleted: 10,
                },
                {
                    __typename: 'Data',
                    stage: 'Curious',
                    members: 10,
                    stepsAdded: 23,
                    stepsCompleted: 34,
                },
                {
                    __typename: 'Data',
                    stage: 'Forgiven',
                    members: 10,
                    stepsAdded: 53,
                    stepsCompleted: 10,
                },
                {
                    __typename: 'Data',
                    stage: 'Growing',
                    members: 10,
                    stepsAdded: 53,
                    stepsCompleted: 10,
                },
                {
                    __typename: 'Data',
                    stage: 'Guiding',
                    members: 10,
                    stepsAdded: 53,
                    stepsCompleted: 10,
                },
            ],
        },
    },
};
