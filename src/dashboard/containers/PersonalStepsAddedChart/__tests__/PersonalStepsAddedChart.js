// Vendors
import React from 'react';
import { waitForElement } from '@testing-library/react';

import { renderWithContext } from '../../../testUtils';
import PersonalStepsAddedChart from '../';

describe('<PersonalStepsAddedChart />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<PersonalStepsAddedChart />, {
            appContext: {
                orgId: 1,
            },
        }).snapshot();
    });

    it('should render properly with chart', async () => {
        const { snapshot, getByText } = renderWithContext(
            <PersonalStepsAddedChart />,
            {
                mocks: {
                    Query: () => ({
                        organizationPathwayStagesReport: () => [
                            {
                                stepsAddedCount: 20,
                                pathwayStage: {
                                    name: 'NO STAGE',
                                },
                            },
                            {
                                stepsAddedCount: 25,
                                pathwayStage: {
                                    name: 'UNINTERESTED',
                                },
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
