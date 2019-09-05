import React from 'react';
import gql from 'graphql-tag';
import { waitForElement } from '@testing-library/react';

import { renderWithContext } from '../../../../testUtils';
import ImpactInfo from '..';
import { GET_IMPACT_REPORT_MOVED } from '../../../containers/PersonalStepsPage/queries';

describe('<ImpactInfo />', () => {
    it('should render properly loading state', () => {
        const { snapshot, unmount } = renderWithContext(
            <ImpactInfo
                query={GET_IMPACT_REPORT_MOVED}
                text={report =>
                    `Text with value ${report.community.impactReport.stageProgressionCount}`
                }
                variables={{ id: 1 }}
            />,
            {
                appContext: {
                    orgId: 1,
                },
            },
        );
        snapshot();
        unmount();
    });

    it('should render properly with data', async () => {
        const { snapshot, getByText } = renderWithContext(
            <ImpactInfo
                query={GET_IMPACT_REPORT_MOVED}
                text={report =>
                    `Text with value ${report.community.impactReport.stageProgressionCount}`
                }
                variables={{ id: 1 }}
            />,
            {
                mocks: {
                    Query: () => ({
                        community: () => ({
                            impactReport: () => ({
                                stageProgressionCount: () => 15,
                            }),
                        }),
                    }),
                },
                appContext: {
                    orgId: 1,
                },
            },
        );

        await waitForElement(() =>
            getByText('Text with value', { exact: false }),
        );
        snapshot();
    });
});
