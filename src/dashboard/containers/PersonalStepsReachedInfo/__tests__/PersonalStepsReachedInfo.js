// Vendors
import React from 'react';
import { waitForElement } from '@testing-library/react';

import { renderWithContext } from '../../../testUtils';
import PersonalStepsReachedInfo from '../';

describe('<PersonalStepsReachedInfo />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<PersonalStepsReachedInfo />).snapshot();
    });

    /*
    it('should render properly with data', async () => {
        const { snapshot, getByText } = renderWithContext(
            <PersonalStepsReachedInfo />,
            {
                mocks: {
                    ImpactReport: () => ({
                            pathwayMovedCount: () => 13
                    }),
                    impactReport: () => ({
                        pathwayMovedCount: () => 13
                    }),
                    Query: () => ({
                        ImpactReport: () =>({
                            pathwayMovedCount: () => 13
                        }),
                        impactReport: () => ({
                            pathwayMovedCount: () => 13
                        }),
                    })
                },
            },
        );

        await waitForElement(() => getByText('This year'));
        snapshot();
    });
    */
});
