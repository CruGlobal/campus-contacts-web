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
                        organizationStagesReport: () => [
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
