import React from 'react';
import gql from 'graphql-tag';
import moment from 'moment';
import { waitForElement } from '@testing-library/react';

import { renderWithContext } from '../../../testUtils';
import StepsChart from '../';

const QUERY = gql`
    query communityStagesReport(
        $period: String!
        $id: ID!
        $endDate: ISO8601DateTime!
    ) {
        community(id: $id) {
            report(period: $period, endDate: $endDate) {
                stagesReport {
                    stepsAddedCount
                    stage {
                        name
                    }
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
                    data.community.report.stagesReport.map((row: any) => ({
                        ['label']: row.stepsAddedCount,
                        ['index']: row.stage.name.toUpperCase(),
                    }))
                }
                label={'label'}
                index={'index'}
                variables={{
                    period: '',
                    id: 1,
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
                    data.community.report.stagesReport.map((row: any) => ({
                        ['label']: row.stepsAddedCount,
                        ['index']: row.stage.name.toUpperCase(),
                    }))
                }
                label={'label'}
                index={'index'}
                variables={{
                    period: '',
                    id: 1,
                    endDate: moment('2019-07-21').format(),
                }}
            />,
            {
                mocks: {
                    Query: () => ({
                        community: () => ({
                            report: () => ({
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
                            }),
                        }),
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
