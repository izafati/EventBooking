public class CaseTriggerHandler extends TriggerHandler {
  private List<Case> oldCaseList, newCaseList;
  private Map<Id, Case> oldCaseMap, newCaseMap;

  public CaseTriggerHandler() {
    oldCaseList = (List<Case>) Trigger.old;
    newCaseList = (List<Case>) Trigger.new;
    oldCaseMap = (Map<Id, Case>) Trigger.oldMap;
    newCaseMap = (Map<Id, Case>) Trigger.newMap;
  }

  protected override void beforeInsert() {
    CaseTriggerHelper.appendErrorToCases(newCaseList);
  }

  protected override void beforeUpdate() {
    CaseTriggerHelper.registerAttendees(newCaseMap);
  }

  protected override void afterUpdate() {
    CaseTriggerHelper.registerAttendees(newCaseMap);
  }
}
