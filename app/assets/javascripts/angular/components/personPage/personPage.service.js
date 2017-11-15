angular
    .module('missionhubApp')
    .factory('personPageService', personPageService);

function personPageService (httpProxy, modelsService, _) {
    return {
        // Determine whether an avatar URL comes from Facebook
        isFacebookAvatar: function (avatarUrl) {
            return _.startsWith(avatarUrl, 'https://graph.facebook.com/');
        },

        // Upload an image file as the person's new avatar
        uploadAvatar: function (person, file) {
            var url = modelsService.getModelUrl(person);
            var form = {
                data: {
                    attributes: {
                        picture: file
                    }
                }
            };
            return httpProxy.submitForm('PUT', url, form, {
                errorMessage: 'error.messages.person_page.upload_avatar'
            });
        },

        // Delete a person's existing avatar
        deleteAvatar: function (person) {
            return httpProxy.put(modelsService.getModelUrl(person), {
                data: {
                    type: 'person',
                    id: person.id,
                    attributes: {
                        picture: null
                    }
                }
            }, {
                errorMessage: 'error.messages.person_page.delete_avatar'
            });
        },

        // Save a person to the server along with all of its relationships
        savePerson: function (person) {
            var attributeNames = [
                'first_name', 'last_name', 'gender', 'student_status'
            ];
            var relationshipNames = [
                'organizational_permissions', 'organizational_labels', 'group_memberships',
                'reverse_contact_assignments', 'email_addresses', 'phone_numbers', 'addresses'
            ];

            var personAttributes = person.serialize({ attributes: attributeNames, relationships: [] }).data;

            var includedRelationships = _.chain(relationshipNames)
                .map(function (relationshipName) {
                    return httpProxy.includedFromModels(person[relationshipName]);
                })
                .flatten()
                .value();

            return httpProxy.post(modelsService.getModelMetadata('person').url.all, {
                data: personAttributes,
                included: includedRelationships
            }, {
                params: { include: relationshipNames.join(',') },
                errorMessage: 'error.messages.person_page.create_person'
            }).then(httpProxy.extractModel);
        }
    };
}
