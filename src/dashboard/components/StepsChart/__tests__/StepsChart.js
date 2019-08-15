import React from 'react';
import gql from 'graphql-tag';
import moment from 'moment';
import { waitForElement } from '@testing-library/react';

import { renderWithContext } from '../../../testUtils';
import StepsChart from '../';

const QUERY = gql`
    query organizationStagesReport(
        $period: String!
        $organizationId: ID!
        $endDate: ISO8601DateTime!
    ) {
        communitiesReport(
            period: $period
            communityIds: $communityIds
            endDate: $endDate
        ) {
            stagesReport {
                stepsAddedCount
                stage {
                    name
                }
            }
        }
    }
`;

describe('<StepsChart />', () => {
    it('should render properly', async () => {
        renderWithContext(
            <StepsChart
                query={QUERY}
                mapData={data =>
                    data.communitiesReport[0].stagesReport.map(row => ({
                        ['label']: row.stepsAddedCount,
                        ['index']: row.stage.name.toUpperCase(),
                    }))
                }
                label={'label'}
                index={'index'}
                variables={{
                    period: '',
                    organizationId: 1,
                    endDate: moment('2019-07-21').format(),
                }}
            />,
        ).snapshot();
    });

    it('should render properly with data', async () => {
        const { snapshot, getByText } = renderWithContext(
            <StepsChart
                query={QUERY}
                mapData={data =>
                    data.communitiesReport[0].stagesReport.map(row => ({
                        ['label']: row.stepsAddedCount,
                        ['index']: row.stage.name.toUpperCase(),
                    }))
                }
                label={'label'}
                index={'index'}
                variables={{
                    period: '',
                    organizationId: 1,
                    endDate: moment('2019-07-21').format(),
                }}
            />,
            {
                mocks: {
                    Query: () => ({
                        communitiesReport: () => [
                            {
                                stagesReport: () => [
                                    {
                                        stepsAddedCount: 20,
                                        stage: {
                                            name: 'NO STAGE',
                                        },
                                    },
                                    {
                                        stepsAddedCount: 25,
                                        stage: {
                                            name: 'UNINTERESTED',
                                        },
                                    },
                                ],
                            },
                        ],
                    }),
                },
                appContext: {
                    orgId: 1,
                },
            },
        );

        await waitForElement(() => getByText('NO STAGE'));
        snapshot();
    });
});
