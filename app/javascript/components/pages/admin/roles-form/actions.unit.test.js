import { expect } from "../../../../test/unit-test-helpers";

import actions from "./actions";

describe("<RolesForm /> - Actions", () => {
  it("should have known properties", () => {
    const clonedActions = { ...actions };

    expect(clonedActions).to.be.an("object");
    [
      "CLEAR_SELECTED_ROLE",
       "FETCH_ROLE",
       "FETCH_ROLE_STARTED",
       "FETCH_ROLE_SUCCESS",
       "FETCH_ROLE_FINISHED",
       "FETCH_ROLE_FAILURE",
       "SAVE_ROLE",
       "SAVE_ROLE_STARTED",
       "SAVE_ROLE_FINISHED",
       "SAVE_ROLE_SUCCESS",
       "SAVE_ROLE_FAILURE"
    ].forEach(property => {
      expect(clonedActions).to.have.property(property);
      delete clonedActions[property];
    });

    expect(clonedActions).to.be.empty;
  });
});