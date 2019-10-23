import React from 'react';
import gql from 'graphql-tag';
import moment from 'moment';
import { waitForElement } from '@testing-library/react';

import { renderWithContext } from '../../../../testUtils';
import { GET_STAGES_REPORT_STEPS_ADDED } from '../../../containers/PersonalStepsPage/queries';

import StepsChart from '..';

describe('<StepsChart />', () => {
    it('should render properly', async () => {
        const { snapshot, unmount } = renderWithContext(
            <StepsChart
                nullContent={'personalStepsAdded'}
                query={GET_STAGES_REPORT_STEPS_ADDED}
                mapData={data =>
                    data.community.report.stagesReport.map((row: any) => ({
                        ['label']: row.personalStepsAddedCount,
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
        );
        snapshot();
        unmount();
    });

    it('should render properly with data', async () => {
        const { snapshot, getByText } = renderWithContext(
            <StepsChart
                nullContent={'personalStepsAdded'}
                query={GET_STAGES_REPORT_STEPS_ADDED}
                mapData={data =>
                    data.community.report.stagesReport.map((row: any) => ({
                        ['label']: row.personalStepsAddedCount,
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
                    orgId: '1',
                },
            },
        );

        await waitForElement(() => getByText('NO STAGE'));
        snapshot();
    });
});
