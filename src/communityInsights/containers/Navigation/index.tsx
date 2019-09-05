import React, { useContext } from 'react';
import styled from '@emotion/styled';
import { NavLink } from 'react-router-dom';
import { useTranslation } from 'react-i18next';

import { AppContext } from '../../../appContext';

const NavigationBar = styled.div`
    background: #005a7f;
    height: 52px;
    padding-top: 15px;
    padding-bottom: 15px;
    padding-left: 18px;
    display: flex;
    justify-content: flex-start;
    border-radius: 0 0 8px 8px;
`;

const Link = styled(NavLink)`
    font-family: Titillium Web;
    font-style: normal;
    font-weight: normal;
    line-height: 21px;
    margin-right: 20px;
    color: white;
    position: relative;

    :hover {
        color: ${({ theme }) => theme.colors.highlight};
        text-decoration: none;
    }

    &.active {
        color: ${({ theme }) => theme.colors.highlight};

        ::after {
            content: '';
            position: absolute;
            bottom: -15px;
            left: 40%;
            border-bottom: 6px solid #f2f2f2;
            border-left: 6px solid transparent;
            border-right: 6px solid transparent;
            width: 0;
        }
    }
`;

const Navigation = () => {
    const { orgId } = useContext(AppContext);
    const { t } = useTranslation('insights');
    return (
        <NavigationBar>
            <Link to={`/ministries/${orgId}/insights/personal`}>
                {t('tabs.personal')}
            </Link>
            <Link to={`/ministries/${orgId}/insights/steps`}>
                {t('tabs.steps')}
            </Link>
            <Link to={`/ministries/${orgId}/insights/interactions`}>
                {t('tabs.interactions')}
            </Link>
            <Link to={`/ministries/${orgId}/insights/challenges`}>
                {t('tabs.challenges')}
            </Link>
        </NavigationBar>
    );
};

export default Navigation;
