import React from 'react';
import { waitForElement } from '@testing-library/react';

import { renderWithContext } from '../../../testUtils';
import PersonalStepsMemberStagesChart from '../';

describe('<PersonalStepsMemberStagesChart />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<PersonalStepsMemberStagesChart />, {
            appContext: {
                orgId: 1,
            },
        }).snapshot();
    });

    it('should render properly with chart', async () => {
        const { snapshot, getByText } = renderWithContext(
            <PersonalStepsMemberStagesChart />,
            {
                mocks: {
                    Query: () => ({
                        organizationStagesReport: () => [
                            {
                                memberCount: 10,
                                stage: {
                                    name: 'NO STAGE',
                                },
                            },
                            {
                                memberCount: 11,
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

        await waitForElement(() => getByText('UNINTERESTED'));
        snapshot();
    });
});
