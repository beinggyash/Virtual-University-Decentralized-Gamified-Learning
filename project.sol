// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VirtualUniversity {
    struct Student {
        bool enrolled;
        uint256 xp;
        uint256[] completedCourses;
    }

    struct Course {
        string name;
        string description;
        uint256 reward;
        bool active;
    }

    mapping(address => Student) public students;
    mapping(uint256 => Course) public courses;
    uint256 public courseCount;

    mapping(address => uint256) public tokenBalances;

    address public admin;

    event StudentEnrolled(address indexed student);
    event CourseCreated(uint256 courseId, string name);
    event CourseCompleted(address indexed student, uint256 courseId);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyEnrolled() {
        require(students[msg.sender].enrolled, "You must be enrolled to perform this action");
        _;
    }

    function enroll() external {
        require(!students[msg.sender].enrolled, "Already enrolled");
        students[msg.sender] = Student({
            enrolled: true,
            xp: 0,
            completedCourses: new uint256[](0)
        });
        emit StudentEnrolled(msg.sender);
    }

    function createCourse(string memory name, string memory description, uint256 reward) external onlyAdmin {
        courses[courseCount] = Course({
            name: name,
            description: description,
            reward: reward,
            active: true
        });
        emit CourseCreated(courseCount, name);
        courseCount++;
    }

    function deactivateCourse(uint256 courseId) external onlyAdmin {
        require(courseId < courseCount, "Invalid course ID");
        courses[courseId].active = false;
    }

    function completeCourse(uint256 courseId) external onlyEnrolled {
        require(courseId < courseCount, "Invalid course ID");
        require(courses[courseId].active, "Course is not active");

        for (uint256 i = 0; i < students[msg.sender].completedCourses.length; i++) {
            require(students[msg.sender].completedCourses[i] != courseId, "Course already completed");
        }

        students[msg.sender].completedCourses.push(courseId);
        students[msg.sender].xp += courses[courseId].reward;
        tokenBalances[msg.sender] += courses[courseId].reward;

        emit CourseCompleted(msg.sender, courseId);
    }

    function getStudentDetails(address studentAddress) external view returns (bool, uint256, uint256[] memory) {
        Student storage student = students[studentAddress];
        return (student.enrolled, student.xp, student.completedCourses);
    }

    function getCourseDetails(uint256 courseId) external view returns (string memory, string memory, uint256, bool) {
        require(courseId < courseCount, "Invalid course ID");
        Course storage course = courses[courseId];
        return (course.name, course.description, course.reward, course.active);
    }
}
