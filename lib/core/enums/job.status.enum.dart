enum JobStatusEnum {
  pending('pending'),
  active('active'),
  inProgress('inprogress'),
  completed('completed'),
  cancelled('cancelled'),
  finished('finished');

  final String value;

  const JobStatusEnum(this.value);

  static JobStatusEnum fromString(String value) {
    return JobStatusEnum.values.firstWhere((e) => e.value == value);
  }
}
