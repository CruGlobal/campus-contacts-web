import React, { useState } from 'react';
import { useQuery } from 'react-apollo-hooks';
import { useTranslation } from 'react-i18next';
import styled from '@emotion/styled';
import { withTheme } from 'emotion-theming';

import leftArrow from '../../assets/icons/arrow-left.svg';
import leftArrowActive from '../../assets/icons/arrow-left-active.svg';
import rightArrow from '../../assets/icons/arrow-right.svg';
import rightArrowActive from '../../assets/icons/arrow-right-active.svg';

const LoadingContainer = styled.div`
    text-align: center;
    padding: 25px;
`;

const TableContainer = styled.table`
    table-layout: fixed;
    width: 100%;
`;

const Header = styled.thead`
    text-align: left;
`;

const Content = styled.tbody``;

const Column = styled.th`
    font-weight: normal;
    font-size: 14px;
    line-height: 60px;
    color: ${({ theme }) => theme.colors.secondary};
    padding: 0 15px;
`;

const Row = styled.tr`
    text-align: left;
    height: 64px;

    :nth-of-type(odd) {
        background-color: #eceef2;
    }
`;

const Cell = styled.td`
    font-weight: normal;
    font-size: 14px;
    line-height: 20px;
    color: ${({ theme }) => theme.colors.primary};
    padding: 0 15px;
    max-width: 200px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    &:first-of-type {
        padding: 0 25px;
    }
    &:last-child {
        padding: 0 5px;
    }
`;

const Pagination = styled.div`
    width: 100%;
    height: 64px;
    display: flex;
    align-items: center;
    justify-content: center;
`;

const LeftArrow = styled.div`
    height: 16px;
    width: 16px;
    background-size: contain;
    background-repeat: no-repeat;
    background-image: url(${leftArrow});
    margin-right: 20px;

    &.active {
        cursor: pointer;
        background-image: url(${leftArrowActive});
    }
`;

const RightArrow = styled.div`
    height: 16px;
    width: 16px;
    background-size: contain;
    background-repeat: no-repeat;
    background-image: url(${rightArrow});
    margin-left: 20px;

    &.active {
        cursor: pointer;
        background-image: url(${rightArrowActive});
    }
`;

const Pages = styled.div`
    display: flex;
`;
const Page = styled.div`
    width: 32px;
    height: 32px;
    font-size: 14px;
    line-height: 20px;
    color: ${({ theme }) => theme.colors.secondary};
    align-items: center;
    display: flex;
    justify-content: center;

    &:not(:last-child) {
        margin-right: 4px;
    }

    &.active {
        border-radius: 16px;
        background-color: ${({ theme }) => theme.colors.highlight};
        color: #ffffff;
    }
`;

const PAGE_SIZE = 5;
const PAGE_NUMBERS_SIZE = 5;

interface Props {
    query: any;
    headers: any;
    mapRows: (data: any) => any;
    mapPage: (data: any) => any;
    variables: any;
}

const Table = ({ query, headers, mapRows, mapPage, variables }: Props) => {
    const [pageNumber, setPageNumber] = useState(1);

    const { data, loading, refetch } = useQuery(query, {
        variables: {
            ...variables,
            first: PAGE_SIZE,
        },
    });
    const { t } = useTranslation('insights');

    if (loading) {
        return <LoadingContainer>{t('loading')}</LoadingContainer>;
    }

    const rows = mapRows(data);
    const page = mapPage(data);

    const nextPage = () => {
        if (page.hasNextPage) {
            refetch({
                first: PAGE_SIZE,
                last: undefined,
                after: page.endCursor,
                before: undefined,
            });
            setPageNumber(pageNumber + 1);
        }
    };

    const previousPage = () => {
        if (page.hasPreviousPage) {
            refetch({
                first: undefined,
                last: PAGE_SIZE,
                after: undefined,
                before: page.startCursor,
            });
            setPageNumber(pageNumber > 1 ? pageNumber - 1 : 0);
        }
    };

    const renderPages = () => {
        const pages = [];
        const pageIndex = Math.floor(PAGE_NUMBERS_SIZE / 2);
        const startIndex =
            pageNumber - pageIndex > 0 ? pageNumber - pageIndex : 1;
        for (let i = startIndex; i < startIndex + PAGE_NUMBERS_SIZE; i++) {
            pages.push(
                <Page key={i} className={i === pageNumber ? 'active' : ''}>
                    {i}
                </Page>,
            );
        }
        return pages;
    };

    return (
        <div>
            <TableContainer>
                <Header>
                    <tr>
                        {headers.map((header: string, index: string) => (
                            <Column key={index}>{header}</Column>
                        ))}
                    </tr>
                </Header>
                <Content>
                    {rows.map((row: any, index: string) => (
                        <Row key={index}>
                            {row.map((cell: string, index: string) => (
                                <Cell key={index}>{cell}</Cell>
                            ))}
                        </Row>
                    ))}
                </Content>
            </TableContainer>
            <Pagination>
                <LeftArrow
                    className={page.hasPreviousPage ? 'active' : ''}
                    onClick={previousPage}
                />
                <Pages>{renderPages()}</Pages>
                <RightArrow
                    className={page.hasNextPage ? 'active' : ''}
                    onClick={nextPage}
                />
            </Pagination>
        </div>
    );
};

export default withTheme(Table);
