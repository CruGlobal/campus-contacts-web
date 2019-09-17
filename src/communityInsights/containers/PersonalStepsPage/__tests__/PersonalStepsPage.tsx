import React from 'react';

import { renderWithContext } from '../../../../testUtils';

import PersonalStepsPage from '..';

describe('<PersonalStepsPage />', () => {
    it('should render properly in loading state', async () => {
        const { snapshot, unmount } = renderWithContext(<PersonalStepsPage />, {
            appContext: {
                orgId: '1',
            },
        });
        snapshot();
        unmount();
    });

    // TODO: Add a test with mocking data when GraphQL schema contains above query
    /*
    it('should render properly with chart', async () => {
        const { snapshot, getByText } = renderWithContext(
            <PersonalStepsPage />,
            {
                mocks: {
                    Query: () => ({
                        communityReport: () => ({
                            communityStagesReport: () => []
                        }),
                        organizationPathwayStagesReport: () => [
                            {
                                stepsAddedCount: 20,
                                memberCount: 10,
                                pathwayStage: {
                                    name: 'NO STAGE',
                                },
                            },
                            {
                                stepsAddedCount: 25,
                                memberCount: 14,
                                pathwayStage: {
                                    name: 'UNINTERESTED',
                                },
                            },
                        ],
                        impactReport: () => ({
                            pathwayMovedCount: () => 13,
                            stepOwnersCount: () => 16
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
    */
});
