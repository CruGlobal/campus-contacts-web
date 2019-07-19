// Vendors
import React from 'react';
import { waitForElement } from '@testing-library/react';

import { renderWithContext } from '../../../testUtils';
import PersonalStepsAddedChart from '../';

describe('<PersonalStepsAddedChart />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<PersonalStepsAddedChart />).snapshot();
    });

    /*
    it('should render properly with chart', async () => {
        const { snapshot, getByText } = renderWithContext(
            <PersonalStepsAddedChart />,
            {
                mocks: {
                    Query: () => ({
                        OrganizationStageReport: () =>  ([
                            { memberCount: 1 },
                            { memberCount: 2 },
                            { memberCount: 3 },
                        ]),
                        organizationPathwayStagesReport: () =>  ([
                            { memberCount: 1 },
                            { memberCount: 2 },
                            { memberCount: 3 },
                        ]),
                    }),
                },
            },
        );

        await waitForElement(() => getByText('NO STAGE'));
        snapshot();
    });
    */
});
