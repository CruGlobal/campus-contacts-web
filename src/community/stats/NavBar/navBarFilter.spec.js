import React from 'react';
import { shallow } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';
import { GET_CURRENT_FILTER } from '../../graphql';
import Filter from './navBarFilter';
import FilterOption from './filterOption';
import moment from 'moment';
import _ from 'lodash';
import { act } from 'react-dom/test-utils'

function createClient(mocks) {
    return new ApolloClient({
        cache: new InMemoryCache(),
        link: new MockLink(mocks)
    })
}

const waitForNextTick = () => new Promise(resolve => setTimeout(resolve))

describe('<NavBarFilter />', () => {
    it('it should render correctly', async () => {
        act(() => {

            const mocks = [
                {
                    request: { query: GET_CURRENT_FILTER },
                    result: {
                        data: {
                            apolloClient: {
                                __typename: 'apolloClient',
                                currentFilter: {
                                    __typename: 'currentFilter',
                                    key: '1W',
                                    startDate: moment()
                                        .subtract(1, 'week')
                                        .format('l'),
                                    endDate: moment().format('l'),
                                },
                            }
                        }
                    }
                }
            ]

            const FilterConfig = [
                {
                    title: 'ALL',
                    filter: {
                        key: 'ALL',
                        startDate: moment()
                            .subtract(5, 'years')
                            .startOf('year')
                            .format('l'),
                        endDate: moment()
                            .endOf('year')
                            .format('l'),
                    },
                },
                {
                    title: '1W',
                    filter: {
                        key: '1W',
                        startDate: moment()
                            .subtract(1, 'week')
                            .format('l'),
                        endDate: moment().format('l'),
                    },
                },
                {
                    title: '1M',
                    filter: {
                        key: '1M',
                        startDate: moment()
                            .subtract(1, 'month')
                            .format('l'),
                        endDate: moment().format('l'),
                    },
                },
                {
                    title: '3M',
                    filter: {
                        key: '3M',
                        startDate: moment()
                            .subtract(3, 'month')
                            .format('l'),
                        endDate: moment().format('l'),
                    },
                },
                {
                    title: '6M',
                    filter: {
                        key: '6M',
                        startDate: moment()
                            .subtract(6, 'month')
                            .format('l'),
                        endDate: moment().format('l'),
                    },
                },
                {
                    title: '1Y',
                    filter: {
                        key: '1Y',
                        startDate: moment()
                            .subtract(1, 'year')
                            .format('l'),
                        endDate: moment().format('l'),
                    },
                },
            ];

            const key = '1W';
            const onFilterClick = jest.fn()

            const wrapper = shallow(
                <ApolloProvider client={createClient(mocks)}>
                    <Filter>
                    {_.map(FilterConfig, option => (
                    <FilterOption
                        key={option.filter.key}
                        title={option.title}
                        filter={option.filter}
                        active={option.filter.key === key}
                        onFilterClick={onFilterClick}
                    />
                ))}
                    </Filter>
                </ApolloProvider>
            );
            expect(wrapper.html()).toBe('<div>Loading</div>');
            waitForNextTick();
            wrapper.update(); 

            expect(wrapper.find(FilterOption).length).toBe(6);
            expect(wrapper.find(FilterOption).at(0).key()).toBe('ALL');
            expect(wrapper.find(FilterOption).at(1).key()).toBe('1W');
            expect(wrapper.find(FilterOption).at(2).key()).toBe('1M');
            expect(wrapper.find(FilterOption).at(3).key()).toBe('3M');
            expect(wrapper.find(FilterOption).at(4).key()).toBe('6M');
            expect(wrapper.find(FilterOption).at(5).key()).toBe('1Y');

            expect(wrapper.find(FilterOption).at(0).prop('title')).toBe('ALL');
            expect(wrapper.find(FilterOption).at(1).prop('title')).toBe('1W');
            expect(wrapper.find(FilterOption).at(2).prop('title')).toBe('1M');
            expect(wrapper.find(FilterOption).at(3).prop('title')).toBe('3M');
            expect(wrapper.find(FilterOption).at(4).prop('title')).toBe('6M');
            expect(wrapper.find(FilterOption).at(5).prop('title')).toBe('1Y');

            expect(wrapper.find(FilterOption).at(0).prop('active')).toBeFalsy();
            expect(wrapper.find(FilterOption).at(1).prop('active')).toBeTruthy();
            expect(wrapper.find(FilterOption).at(2).prop('active')).toBeFalsy();
            expect(wrapper.find(FilterOption).at(3).prop('active')).toBeFalsy();
            expect(wrapper.find(FilterOption).at(4).prop('active')).toBeFalsy();
            expect(wrapper.find(FilterOption).at(5).prop('active')).toBeFalsy();
        })       
    });
});
