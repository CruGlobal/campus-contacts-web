import React from 'react';
import gql from 'graphql-tag';

import { renderWithContext } from '../../../../testUtils';
import { GET_STEPS_COMPLETED_REPORT } from '../../../containers/StepsOfFaithPage/queries';
import FiltersChart from '..';

describe('<FiltersChart />', () => {
    it('should render properly', async () => {
        const { snapshot, unmount } = renderWithContext(
            <FiltersChart
                nullContent={'stepsOfFaithCompleted'}
                query={GET_STEPS_COMPLETED_REPORT}
                mapData={() => {}}
                label={'test label'}
            />,
        );
        snapshot();
        unmount();
    });

    // TODO: Add a test with mocking data when GraphQL schema contains above query
});
