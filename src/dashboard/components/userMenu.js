import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import AppContext from '../appContext';

const UserContainer = styled.div`
    width: 200px;
    height: 30px;
    flex-grow: 1;
    justify-content: flex-end;
    display: flex;
    align-items: center;
    position: relative;
`;

const UserAvatar = styled.img`
    width: 36px;
    height: 36px;
    border-radius: 30px;
    cursor: pointer;
`;

const UserName = styled.div`
    line-height: 20px;
    color: #505256;
    margin-right: 15px;
`;

const Menu = styled.ul`
    position: absolute;
    background-color: #06415f;
    border-top: none;
    list-style: none;
    top: 51px;
    padding: 0;
    width: 120px;
`;

const MenuItem = styled.li`
    line-height: 20px;
    height: 40px;
    font-size: 14px;
    text-align: center;
    width: 100%;
    padding-top: 10px;
    padding-bottom: 10px;

    a {
        display: block;
        width: 100%;
        height: 100%;
        color: white;
        text-decoration: none;
    }

    a:hover {
        color: white;
        text-decoration: none;
    }

    :hover {
        background-color: #085378;
    }
`;

const Item = ({ label, href, onClick }) => (
    <MenuItem>
        <a href={href} onClick={onClick}>
            {label}
        </a>
    </MenuItem>
);

const UserMenu = () => {
    const appContext = React.useContext(AppContext);
    const { person, root } = appContext;

    const [isOpened, setOpened] = React.useState(false);
    return (
        <UserContainer>
            <UserName>{person.full_name}</UserName>
            <UserAvatar
                src={person.picture}
                onClick={() => setOpened(!isOpened)}
            />
            {isOpened && (
                <Menu>
                    <Item
                        label={'My Profile'}
                        href={`/people/${person.id}/profile`}
                    />
                    <Item label={'Preferences'} href={'/user-preferences'} />
                    <Item
                        label={'About'}
                        href={'#'}
                        onClick={() => root.openAboutModal()}
                    />
                    <Item
                        label={'Sign Out'}
                        href={'#'}
                        onClick={() => appContext.auth.destroyTheKeyAccess()}
                    />
                </Menu>
            )}
        </UserContainer>
    );
};

export default UserMenu;

UserMenu.propTypes = {
    person: PropTypes.object,
};
