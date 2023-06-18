enum Priority_Enum {
  VeryImportant,
  Important,
  Normal,
  LessImportant,
  NotImportant,
}

Map<Priority_Enum, String> priorityMap = {
  Priority_Enum.VeryImportant: "very important",
  Priority_Enum.Important: "important",
  Priority_Enum.Normal: "normal",
  Priority_Enum.LessImportant: "less important",
  Priority_Enum.NotImportant: "not important",
};

Map<String, Priority_Enum> priorityMapReverse = {
  "very important": Priority_Enum.VeryImportant,
  "important": Priority_Enum.Important,
  "normal": Priority_Enum.Normal,
  "less important": Priority_Enum.LessImportant,
  "not important": Priority_Enum.NotImportant,
};
