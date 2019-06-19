// Vendors
import React from 'react';
import { waitForElement } from '@testing-library/react';
// Project
import { renderWithContext } from '../../../testUtils';
// Subject
import MemberStagesChart from '../';

describe('<MemberStagesChart />', () => {
    it('should render properly loading state', async () => {
        renderWithContext(<MemberStagesChart />).snapshot();
    });

    /* It has to wait until this query is available in the schema
    it('should render properly with chart', async () => {
        const { snapshot, getByText } = renderWithContext(
            <MemberStagesChart />,
            {
                mocks: {
                    Query: () => ({
                        stages_report: () => ({
                            data: () => ([
                                {
                                    __typename: 'Data',
                                    pathway_stage: 'NO STAGE',
                                    member_count: 10,
                                    steps_added_count: 12,
                                    steps_completed_count: 37,
                                },
                                {
                                    __typename: 'Data',
                                    pathway_stage: 'NOT SURE',
                                    member_count: 11,
                                    steps_added_count: 34,
                                    steps_completed_count: 37,
                                }
                            ])
                        })
                    })
                },
            },
        );

        await waitForElement(() => getByText('NO STAGE'));
        snapshot();
    });
*/
});
